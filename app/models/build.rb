class Build < ActiveRecord::Base
  REPO_URL  = 'git@github.com:ivanilves/ptu.git'
  BASE_PORT = 10000

  before_create { |b| b.build_id = "#{b.name.gsub(' ', '-').downcase}-#{SecureRandom.hex(3)}" }
  before_create :create_tailored_build
  after_destroy :delete_tailored_build

  def self.build_root
    CloudPort::Application.config.build_root
  end

  def self.exposed_port
    BASE_PORT + rand(10000)
  end

  def initialize(
    name:         'dummy',
    ssh_server:   'gateway.cloudport.net',
    ssh_username: 'cloudport',
    ssh_password: 'drowssap',
    target_host:  '127.0.0.1:22',
    exposed_bind: '0.0.0.0',
    exposed_port: self.class.exposed_port
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
    "#{self.class.build_root}/#{build_id}"
  end

  private

  def create_tailored_build
    FileUtils.mkdir(build_path)
    system("git clone --depth 1 #{REPO_URL} #{build_path} &>/dev/null")
    FileUtils.chdir(build_path) do
      self.status = !!system("./script/tailor #{tailor_opts} &>tailor.log")
    end

    return true
  end

  def tailor_opts
    "-n #{name} -s #{ssh_server} -u #{ssh_username} -p #{ssh_password} -t #{target_host} -b #{exposed_bind} -e #{exposed_port}"
  end

  def delete_tailored_build
    FileUtils.rm_rf(build_path)
  end
end
