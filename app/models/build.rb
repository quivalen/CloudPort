class Build < ActiveRecord::Base

  has_many :connections

  before_create { |b| b.build_id = SecureRandom.hex(3) }

  before_create :create_tailored_build
  after_destroy :delete_tailored_build

  before_create :create_docker_container
  after_destroy :delete_docker_container

  def self.ssh_port_offset
    @@ssh_port_offset ||= CloudPort::Application.config.ssh_port_offset
  end

  def self.build_root
    @@build_root ||= CloudPort::Application.config.build_root
  end

  def self.ptu_repo_url
    @@ptu_repo_url ||= CloudPort::Application.config.ptu_repo_url
  end

  def self.ptu_repo_tar
    @@ptu_repo_tar ||= CloudPort::Application.config.ptu_repo_tar
  end

  def self.ptu_tailor_command
    @@ptu_tailor_command ||= CloudPort::Application.config.ptu_tailor_command
  end

  def self.operating_systems
    @@operating_systems ||= {
      linux:   'GNU/Linux',
      darwin:  'MacOS X',
      windows: 'Windows',
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

    self.ssh_server_port = exposed_port + self.class.ssh_port_offset
  end

  def ssh_server
    @ssh_server ||= "#{ssh_server_address}:#{ssh_server_port.to_s}"
  end

  def target_host
    @target_host ||= "#{target_address}:#{target_port.to_s}"
  end

  def exposed_host
    @exposed_host ||= "#{ssh_server_address}:#{exposed_port.to_s}"
  end

  def build_path
    @build_path ||= "#{self.class.build_root}/#{build_id}"
  end

  def binary_path
    @binary_path ||= "#{build_path}/bin"
  end

  def binary_extension
    return '.exe' if windows?

    ''
  end

  def binary_file_name
    @binary_file ||= "ptu-#{operating_system}-#{cpu_architecture}-#{build_id}#{binary_extension}"
  end

  def docker_container
    @docker_container ||= Docker::Container.get(docker_container_id)
  end

  def operating_system
    super.to_sym
  end

  def linux?
    operating_system == :linux
  end

  def darwin?
    operating_system == :darwin
  end

  def windows?
    operating_system == :windows
  end

  def os
    unless @os
      name = self.class.operating_systems[operating_system]
      bits = self.class.cpu_architectures[cpu_architecture]

      @os = "#{name} (#{bits})"
    end

    @os
  end

  def tip
    if windows?
      return "Unbelievable, all you need to do is just download and run application we have built!"
    end

    "Download application. Set executable bit with \"chmod +x #{binary_file_name}\" and run it!"
  end

  # Probes container's tunneled remote connection addresses
  #
  # returns [Array] remote connection address in form 'addr:port'
  def probe_remotes
    netstat.map { |l| l.split[4] }
  end

  # Synchronize connection records in database with reality
  #
  # returns [ActiveRecord::Associations::CollectionProxy] actual connections
  def synchronize_connections!
    remotes     = probe_remotes
    connections = self.connections

    connections.each do |c|
      c.disconnect! unless remotes.include?(c.remote)
    end

    remotes.each do |r|
      unless self.connections.find_by_remote(r)
        Connection.create(build: self, remote: r)
      end
    end

    self.connections.reset
  end

  private

  def create_tailored_build
    return false unless prepare_build_path

    tailor_build!
  end

  def prepare_build_path
    FileUtils.mkdir(build_path)

    if File.exist?(self.class.ptu_repo_tar)
      system("tar -C #{build_path} -xf #{self.class.ptu_repo_tar}")
    else
      system("git clone --depth 1 #{self.class.ptu_repo_url} #{build_path}")
    end
  end

  def tailor_build!
    FileUtils.chdir(build_path) do
      self.status = !!system("#{ptu_tailor_environment} #{self.class.ptu_tailor_command} #{ptu_tailor_options}")
    end

    self.status
  end

  def ptu_tailor_environment
    "SKIP_CI=yes BUILD_ID=#{build_id} OPERATING_SYSTEMS=#{operating_system} CPU_ARCHITECTURES=#{cpu_architecture}"
  end

  def ptu_tailor_options
    "-n #{name} -s #{ssh_server} -u #{ssh_username} -p #{ssh_password} -t #{target_host} -b #{exposed_bind} -e #{exposed_port}"
  end

  def delete_tailored_build
    FileUtils.rm_rf(build_path)
  end

  def create_docker_container
    guest_ssh_port     = '22/tcp'
    host_ssh_port      = ssh_server_port.to_s
    guest_exposed_port = "#{exposed_port.to_s}/tcp"
    host_exposed_port  = exposed_port.to_s

    container = Docker::Container.create(
      'Image'        => CloudPort::Application.config.docker_image,
      'ExposedPorts' => {
        guest_ssh_port => {}, guest_exposed_port => {},
      },
      'PortBindings' => {
        guest_ssh_port      => [{ 'HostPort' => host_ssh_port }],
        guest_exposed_port  => [{ 'HostPort' => host_exposed_port }],
      },
      'name' => build_id,
    )

    container.start

    container.exec(
      ['passwd', 'root'],
      stdin: StringIO.new("#{ssh_password}\n#{ssh_password}")
    )

    container.exec(
      ['bash', '-c', 'echo GatewayPorts yes >>/etc/ssh/sshd_config']
    )

    container.exec(
      ['kill', '-HUP', '1']
    )

    self.docker_container_id = container.id
  end

  def delete_docker_container
    container = docker_container

    container.stop if container.info['State']['Running']
    container.delete
  end

  def netstat
    docker_container.exec(
      ['netstat', '-n', '|', 'grep ']
    )[0][0].split(%r{\n}).grep(%r{:#{exposed_port.to_s}\s.*\sESTABLISHED$})
  end

end
