class Build < ActiveRecord::Base
  REPO_URL = 'git@github.com:ivanilves/ptu.git'

  attr_reader :name, :ssh_server, :ssh_username, :ssh_password, :target_host, :exposed_bind, :exposed_port

  def self.build_root
    '/tmp'
  end

  def initialize(name:, ssh_server:, ssh_username:, ssh_password:, target_host: '127.0.0.1:22', exposed_bind: '0.0.0.0', exposed_port:)
    @name         = name
    @ssh_server   = ssh_server
    @ssh_username = ssh_username
    @ssh_password = ssh_password
    @target_host  = target_host
    @exposed_bind = exposed_bind
    @exposed_port = exposed_port

    @build_id     = "#{@name}-#{SecureRandom.hex(3)}"
  end

  def exposed_host
    "#{@exposed_bind}:#{@exposed_port.to_s}"
  end

  def build_path

  end

  private

  def tailor!
    Dir.chdir(self.class.build_root)
  end
end
