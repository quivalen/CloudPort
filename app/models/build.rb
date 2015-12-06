class Build < ActiveRecord::Base
  BASE_PORT = 10000

  before_create { |b| b.build_id = SecureRandom.hex(7) }
  before_create :create_tailored_build
  after_destroy :delete_tailored_build

  def self.build_root
    @@build_root ||= CloudPort::Application.config.build_root
  end

  def self.repo_url
    @@repo_url ||= ENV['PTU_REPO_URL'].strip || 'git@github.com:ivanilves/ptu.git'
  end

  def self.tailor_command
    @@tailor_command ||= ENV['PTU_TAILOR_COMMAND'].strip || 'script/tailor'
  end

  def self.random_exposed_port
    BASE_PORT + rand(10000)
  end

  def initialize(
    name:         'dummy',
    ssh_server:   'gateway.cloudport.net',
    ssh_username: 'cloudport',
    ssh_password: 'drowssap',
    target_host:  '127.0.0.1:22',
    exposed_bind: '0.0.0.0',
    exposed_port: self.class.random_exposed_port
  )
    super

    @name         = name
    @ssh_server   = ssh_server
    @ssh_username = ssh_username
    @ssh_password = ssh_password
    @target_host  = target_host
    @exposed_bind = exposed_bind
    @exposed_port = exposed_port
  end

  def exposed_host
    "#{exposed_bind}:#{exposed_port.to_s}"
  end

  def build_path
    @build_path ||= "#{self.class.build_root}/#{self.build_id}"
  end

  def binary_path
    @binary_path ||= "#{build_path}/bin"
  end

  def binary_files
    unless @binary_files
      @binary_files = []
      Dir.new(binary_path).each do |f|
        @binary_files << f if f.match(/^ptu-/)
      end
    end

    @binary_files
  end

  private

  def create_tailored_build
    FileUtils.mkdir(build_path)
    system("git clone --depth 1 #{self.class.repo_url} #{build_path} &>/dev/null")
    FileUtils.chdir(build_path) do
      self.status = !!system("#{self.class.tailor_command} #{tailor_options} &>tailor.log")
    end

    !!self.status
  end

  def tailor_options
    "-n #{name} -s #{ssh_server} -u #{ssh_username} -p #{ssh_password} -t #{target_host} -b #{exposed_bind} -e #{exposed_port}"
  end

  def delete_tailored_build
    FileUtils.rm_rf(build_path)
  end
end
