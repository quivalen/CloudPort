class Build < ActiveRecord::Base
  BASE_PORT   = 10000
  PORT_OFFSET = 10000

  PTU_REPO_URL       = 'file:///deploy/ptu'
  PTU_TAILOR_COMMAND = 'script/tailor'
  BINARY_FILE_MATCH  = /^ptu-/

  DOCKER_IMAGE = 'rastasheep/ubuntu-sshd:14.04'

  before_create { |b| b.build_id = SecureRandom.hex(7) }

  before_create :create_tailored_build
  after_destroy :delete_tailored_build

  before_create :create_docker_container
  after_destroy :delete_docker_container

  def self.build_root
    @@build_root ||= CloudPort::Application.config.build_root
  end

  def self.repo_url
    @@repo_url ||= ENV['PTU_REPO_URL'] || PTU_REPO_URL
  end

  def self.tailor_command
    @@tailor_command ||= ENV['PTU_TAILOR_COMMAND'] || PTU_TAILOR_COMMAND
  end

  def self.random_password
    SecureRandom.hex(20)
  end

  def self.random_exposed_port
    BASE_PORT + rand(PORT_OFFSET)
  end

  def initialize(
    name:         Rails.application.class.to_s.split("::").first.downcase,
    ssh_server:   'echo.cloudport.net',
    ssh_username: 'root',
    ssh_password: self.class.random_password,
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

  def ssh_server
    "#{@ssh_server}:#{ssh_port.to_s}"
  end

  def ssh_port
    @ssh_port ||= exposed_port + PORT_OFFSET
  end

  def build_path
    @build_path ||= "#{self.class.build_root}/#{build_id}"
  end

  def binary_path
    @binary_path ||= "#{build_path}/bin"
  end

  def binary_files
    unless @binary_files
      @binary_files = []
      Dir.new(binary_path).each do |f|
        @binary_files << f if f.match(BINARY_FILE_MATCH)
      end
    end

    @binary_files
  end

  def docker_container
    @docker_container ||= Docker::Container.get(docker_container_id)
  end

  private

  def create_tailored_build
    FileUtils.mkdir(build_path)
    system("git clone --depth 1 #{self.class.repo_url} #{build_path}")
    FileUtils.chdir(build_path) do
      self.status = !!system("#{self.class.tailor_command} #{tailor_options} >tailor.log 2>tailor.err")
    end

    !!status
  end

  def tailor_options
    "-n #{name} -s #{ssh_server} -u #{ssh_username} -p #{ssh_password} -t #{target_host} -b #{exposed_bind} -e #{exposed_port}"
  end

  def delete_tailored_build
    FileUtils.rm_rf(build_path)
  end

  def create_docker_container
    guest_ssh_port     = '22/tcp'
    host_ssh_port      = ssh_port.to_s
    guest_exposed_port = "#{exposed_port.to_s}/tcp"
    host_exposed_port  = exposed_port.to_s

    container = Docker::Container.create(
      'Image' => DOCKER_IMAGE,
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

    self.docker_container_id = container.id
  end

  def delete_docker_container
    container = docker_container

    container.stop if container.info['State']['Running']
    container.delete
  end

end
