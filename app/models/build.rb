class Build < ActiveRecord::Base
  REPO_URL = 'git@github.com:ivanilves/ptu.git'

  before_create { |b| b.build_id = "#{b.name.gsub(' ', '-').downcase}-#{SecureRandom.hex(3)}" }
  before_create { |b| b.tailor }

  def self.build_root
    '/opt/cloudport/builds'
  end

  def self.exposed_port
    10000 + rand(10000)
  end

  def initialize(
    name:,
    ssh_server:   'gateway.cloudport.net',
    ssh_username: 'cloudport',
    ssh_password: 'drowssap',
    target_host:  '127.0.0.1:22',
    exposed_bind: '0.0.0.0',
    exposed_port: self.class.exposed_port
  )
    super

    @name = name

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
    "#{self.class.build_root}/#{build_id}"
  end

  #private

  def tailor
    Dir.mkdir(build_path)
    system("git clone --depth 1 #{REPO_URL} #{build_path} &>/dev/null")
    Dir.chdir(build_path) do
      self.status = !!system("./script/tailor #{tailor_opts}")
    end

    return true
  end

  def tailor_opts
    "-n #{name} -s #{ssh_server} -u #{ssh_username} -p #{ssh_password} -t #{target_host} -b #{exposed_bind} -e #{exposed_port}"
  end
end
