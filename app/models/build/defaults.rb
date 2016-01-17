class Build::Defaults

  def self.reset!
    @@ssh_server    = nil
    @@ssh_password  = nil
    @@exposed_port  = nil
  end

  def self.name
    @@name ||= Rails.application.class.to_s.split("::").first.downcase
  end

  def self.ssh_server
    @@ssh_server ||= nil

    unless @@ssh_server
      host = CloudPort::Application.config.hostname
      port = exposed_port + CloudPort::Application.config.ssh_port_offset

      @@ssh_server ||= "#{host}:#{port.to_s}"
    end

    @@ssh_server
  end

  def self.ssh_username
    'root'
  end

  def self.ssh_password
    @@ssh_password ||= SecureRandom.hex(20)
  end

  def self.target_host
    '127.0.0.1:22'
  end

  def self.exposed_bind
    '0.0.0.0'
  end

  def self.exposed_port
    @@exposed_port ||= nil

    unless @@exposed_port
      base = CloudPort::Application.config.ssh_base_port
      step = rand(CloudPort::Application.config.ssh_port_offset)

      @@exposed_port = base + step
    end

    @@exposed_port
  end

end
