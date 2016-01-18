class Build::Defaults

  def self.name
    Rails.application.class.to_s.split("::").first.downcase
  end

  def self.ssh_server_address
    CloudPort::Application.config.hostname
  end

  def self.ssh_username
    'root'
  end

  def self.ssh_password
    SecureRandom.hex(20)
  end

  def self.target_address
    '127.0.0.1'
  end

  def self.target_port
    22
  end

  def self.exposed_bind
    '0.0.0.0'
  end

  def self.exposed_port
    base = CloudPort::Application.config.ssh_base_port
    step = rand(CloudPort::Application.config.ssh_port_offset)

    base + step
  end

  def self.operating_system
    :windows
  end

  def self.cpu_architecture
    :amd64
  end

end
