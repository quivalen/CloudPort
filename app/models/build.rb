class Build < ActiveRecord::Base
  before_create { |b| b.build_id = SecureRandom.hex(3) }

  before_create :create_tailored_build
  after_destroy :delete_tailored_build

  before_create :create_docker_container
  after_destroy :delete_docker_container

  def self.build_root
    @@build_root ||= CloudPort::Application.config.build_root
  end

  def self.ptu_repo_url
    @@ptu_repo_url ||= CloudPort::Application.config.ptu_repo_url
  end

  def self.ptu_tailor_command
    @@ptu_tailor_command ||= CloudPort::Application.config.ptu_tailor_command
  end

  def self.docker_image
    @@docker_image ||= CloudPort::Application.config.docker_image
  end

  def initialize(
    name:         Build::Defaults.name,
    ssh_server:   Build::Defaults.ssh_server,
    ssh_username: Build::Defaults.ssh_username,
    ssh_password: Build::Defaults.ssh_password,
    target_host:  Build::Defaults.target_host,
    exposed_bind: Build::Defaults.exposed_bind,
    exposed_port: Build::Defaults.exposed_port
  )
    super

    @name         = name
    @ssh_server   = ssh_server
    @ssh_username = ssh_username
    @ssh_password = ssh_password
    @target_host  = target_host
    @exposed_bind = exposed_bind
    @exposed_port = exposed_port

    Build::Defaults.reset!
  end

  def ssh_port
    @ssh_port ||= ssh_server.sub(%r{.*:},'').to_i
  end

  def exposed_host
    @exposed_host ||= "#{exposed_bind}:#{exposed_port.to_s}"
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
        @binary_files << f if f.match(%r{^ptu})
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
    system("git clone --depth 1 #{self.class.ptu_repo_url} #{build_path}")
    FileUtils.chdir(build_path) do
      self.status = !!system("SKIP_CI=yes #{self.class.ptu_tailor_command} #{ptu_tailor_options} >tailor.log 2>tailor.err")
    end

    !!self.status
  end

  def ptu_tailor_options
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
      'Image'        => self.class.docker_image,
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

end
