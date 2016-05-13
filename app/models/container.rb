class Container < ActiveRecord::Base

  SSH_PORT = 22

  belongs_to :build

  has_many :connections,    dependent: :delete_all
  has_many :failover_rules, dependent: :delete_all

  before_validation :create_docker_container, on: :create
  before_destroy    :delete_docker_container

  validates :docker_container_id,
    presence: true,
    uniqueness: true,
    format: { with: /\A[0-9a-f]+\z/ },
    length: { is: 64 }

  validates_associated :connections

  # Get reference to a Docker container serving build
  #
  # return [Docker::Container] a reference to Docker container
  def docker_container
    Docker::Container.get(docker_container_id)
  end

  # Checks, if Docker container exists
  #
  # return [Boolean] does it exist?
  def docker_container_exists?
    !!docker_container
  rescue Docker::Error::NotFoundError
    false
  end

  # Re-create backing Docker container
  #
  # return [Boolean] always true (or fails loudly)
  def recreate_docker_container!
    delete_docker_container if docker_container_exists?
    create_docker_container

    save!

    true
  end

  # Get container's connection remote addresses (and is connection forwarded or direct)
  #
  # return [Hash] remote connection address/type in form { 'addr:port' => true|false }
  def remotes
    remotes = {}

    probe_remote_connections.each do |l, r|
      remotes[r] = !!!l.match(%r{^[0-9\.]+:#{SSH_PORT}$})
    end

    remotes
  end

  # Synchronize connection records in database with reality
  #
  # return [ActiveRecord::Associations::CollectionProxy] actual connections
  def synchronize_connections!
    connections = self.connections

    connections.each do |c|
      c.disconnect! unless remotes.include?(c.remote)
    end

    remotes.each do |r, f|
      unless self.connections.find_by_remote(r)
        self.connections.build(remote: r, is_forwarded: f).save
      end
    end

    self.connections.reset
  end

  # return [String] direct remote connection address, if any
  def direct_remote
    return nil unless self.connections.direct.first

    self.connections.direct.first.remote
  end

  # return [Array] forwarded [tunneled] remote connection addresses, if any
  def forwarded_remotes
    return nil if self.connections.forwarded.empty?

    self.connections.forwarded.map { |c| c.remote }
  end

  # return [String] container's IP address
  def ip_address
    docker_container.info['NetworkSettings']['IPAddress']
  end

  private

  def create_docker_container
    guest_ssh_port     = "#{SSH_PORT}/tcp"
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
      'Labels' => { 'environment' => Rails.env },
      'name'   => "worker-#{build.ptu_build_id}",
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

    container.delete(force: true)
  end

  def remote_connection_filter_regex
    %r{\s+[0-9\.]+:(#{SSH_PORT}|#{build.exposed_port.to_s})\s+[0-9\.]+:[0-9]+\s+ESTABLISHED$}
  end

  def netstat
    docker_container.exec(['netstat', '-n', '|', 'grep '])[0][0].split(%r{\n}).grep(remote_connection_filter_regex)
  end

  def probe_remote_connections
    netstat.map { |l| [l.split[3], l.split[4]] }.sort.uniq
  end

end
