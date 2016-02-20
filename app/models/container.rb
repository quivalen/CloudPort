class Container < ActiveRecord::Base

  belongs_to :build
  has_many :connections, dependent: :destroy

  before_create :create_docker_container
  after_destroy :delete_docker_container

  # Gets reference to a Docker container serving build
  #
  # returns [Docker::Container] a reference to Docker container
  def docker_container
    @docker_container ||= Docker::Container.get(docker_container_id)
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
        self.connections.build(remote: r)
      end
    end

    self.connections.reset
  end

  private

  def create_docker_container
    guest_ssh_port     = '22/tcp'
    host_ssh_port      = build.ssh_server_port.to_s
    guest_exposed_port = "#{build.exposed_port.to_s}/tcp"
    host_exposed_port  = build.exposed_port.to_s

    container = Docker::Container.create(
      'Image'        => CloudPort::Application.config.docker_image,
      'ExposedPorts' => {
        guest_ssh_port => {}, guest_exposed_port => {},
      },
      'PortBindings' => {
        guest_ssh_port      => [{ 'HostPort' => host_ssh_port }],
        guest_exposed_port  => [{ 'HostPort' => host_exposed_port }],
      },
      'name' => build.ptu_build_id,
    )

    container.start

    container.exec(
      ['passwd', 'root'],
      stdin: StringIO.new("#{build.ssh_password}\n#{build.ssh_password}")
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
