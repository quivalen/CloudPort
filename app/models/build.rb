#
# Build class is a heart of CloudPort.
# It represents a p.t.u. build, tailored for a one single specific task.
# Each build (client-side) has a Docker container (server-side) assigned.
# Each build is designed to be used exclusively and destroyed after using.
#
class Build < ActiveRecord::Base

  extend  Build::Globals
  include Build::Tips

  has_one :container, dependent: :delete

  before_create :create_tailored_build
  after_destroy :delete_tailored_build
  after_create  { |b| Container.create!(build: b) }

  validates :ptu_build_id,
    presence: true,
    uniqueness: true,
    format: { with: /\A[0-9a-f]+\z/ },
    length: { is: 6 }

  validates :ssh_server_address,
    presence: true,
    format: { with: HOSTNAME_REGEX }

  validates :ssh_server_port,
    presence: true,
    uniqueness: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 20000,
      less_than: 30000
    }

  validates :ssh_username,
    presence: true,
    format: { with: /\A[a-z][a-z0-9_]+\z/ }

  validates :ssh_password,
    presence: true,
    length: { minimum: 20 }

  validates :target_address,
    presence: true,
    format: { with: HOSTNAME_REGEX }

  validates :target_port,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than: 0,
      less_than: 65535
    }

  validates :exposed_bind,
    presence: true,
    format: { with: /\A0\.0\.0\.0\z/ }

  validates :exposed_port,
    presence: true,
    uniqueness: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 10000,
      less_than: 20000
    }

  validates :operating_system,
    presence: true,
    inclusion: { in: %w(linux darwin windows) }

  validates :cpu_architecture,
    presence: true,
    inclusion: { in: %w(amd64 386) }

  validates :client_ip_address,
    presence: true,
    format: { with: IP_ADDR_REGEX }

  def self.operating_systems
    @@operating_systems ||= {
      'linux'   => 'GNU/Linux',
      'darwin'  => 'MacOS X',
      'windows' => 'Windows',
    }
  end

  def self.cpu_architectures
    @@cpu_architectures ||= { 'amd64' => '64-bit', '386' => '32-bit' }
  end

  def initialize(
    name:               Build::Defaults.name,
    ssh_server_address: Build::Defaults.ssh_server_address,
    ssh_username:       Build::Defaults.ssh_username,
    ssh_password:       Build::Defaults.ssh_password,
    target_address:     Build::Defaults.target_address,
    target_port:        Build::Defaults.target_port,
    exposed_bind:       Build::Defaults.exposed_bind,
    exposed_port:       Build::Defaults.exposed_port,
    operating_system:   Build::Defaults.operating_system,
    cpu_architecture:   Build::Defaults.cpu_architecture,
    client_ip_address:  Build::Defaults.client_ip_address
  )
    super

    self.ptu_build_id     = SecureRandom.hex(3)
    self.ssh_server_port  = exposed_port + self.class.ssh_port_offset
  end

  # return [String] an SSH server host:port to connect p.t.u. application
  def ssh_server
    @ssh_server ||= "#{ssh_server_address}:#{ssh_server_port.to_s}"
  end

  # return [String] a (client-side) target host to forward tunnel traffic to
  def target_host
    @target_host ||= "#{target_address}:#{target_port.to_s}"
  end

  # return [String] a TCP server host:port to listen for remote connections
  def exposed_host
    @exposed_host ||= "#{ssh_server_address}:#{exposed_port.to_s}"
  end

  # return [String] a filesystem path where this particular p.t.u. build is stored
  def build_path
    @build_path ||= "#{self.class.build_root}/#{ptu_build_id}"
  end

  # return [String] a filesystem path where binary file for this particular p.t.u. build is located
  def binary_path
    "#{build_path}/bin"
  end

  # return [String] where to dump STDOUT of this p.t.u. build?
  def build_stdout_destination
    "#{build_path}/STDOUT"
  end

  # return [String] where to dump STDERR of this p.t.u. build?
  def build_stderr_destination
    "#{build_path}/STDERR"
  end

  # return [String] where to dump STDOUT and STDERR of the p.t.u build prepare process
  def build_prepare_log
    "#{self.class.build_root}/_PREPARE.#{ptu_build_id}"
  end

  # return [Boolean] built for Linux?
  def linux?
    operating_system == 'linux'
  end

  # return [Boolean] built for MacOSX?
  def darwin?
    operating_system == 'darwin'
  end

  # return [Boolean] built for Windows?
  def windows?
    operating_system == 'windows'
  end

  # return [String] a p.t.u. tailored binary file extension, if applicable
  def binary_extension
    return '.exe' if windows?

    ''
  end

  # return [String] p.t.u. tailored binary file name
  def binary_file_name
    @binary_file ||= "ptu-#{operating_system}-#{cpu_architecture}-#{ptu_build_id}#{binary_extension}"
  end

  private

  def create_tailored_build
    return false unless prepare_build_path

    tailor_build!
  end

  def prepare_build_path
    FileUtils.mkdir(build_path)

    if File.exist?(self.class.ptu_repo_tar)
      system("tar -C #{build_path} -xf #{self.class.ptu_repo_tar} #{prepare_output_redirects}")
    else
      system("git clone --depth 1 #{self.class.ptu_repo_url} #{build_path} #{prepare_output_redirects}")
    end
  end

  def tailor_build!
    FileUtils.chdir(build_path) do
      self.status = !!system("#{ptu_tailor_environment} #{self.class.ptu_tailor_command} #{ptu_tailor_options} #{build_output_redirects}")
    end

    self.status
  end

  def ptu_tailor_environment
    "SKIP_CI=yes BUILD_ID=#{ptu_build_id} OPERATING_SYSTEMS=#{operating_system} CPU_ARCHITECTURES=#{cpu_architecture}"
  end

  def ptu_tailor_options
    "-n #{name} -s #{ssh_server} -u #{ssh_username} -p #{ssh_password} -t #{target_host} -b #{exposed_bind} -e #{exposed_port} -f #{FailoverRule::DESTINATION_PORT}"
  end

  def build_output_redirects
    ">#{build_stdout_destination} 2>#{build_stderr_destination}"
  end

  def prepare_output_redirects
    ">#{build_prepare_log} 2>&1"
  end

  def delete_tailored_build
    FileUtils.rm_rf(build_path)
    FileUtils.rm_rf(build_prepare_log)
  end

end
