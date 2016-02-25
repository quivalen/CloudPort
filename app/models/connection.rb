class Connection < ActiveRecord::Base

  belongs_to :container

  default_scope { where(is_connected: true) }

  ZERO_TIMESTAMP = '0000-01-01 00:00:00'.to_datetime

  def initialize(remote:, is_forwarded: false)
    super

    self.connected_at     = Time.now
    self.disconnected_at  = ZERO_TIMESTAMP
  end

  # Is connection active (connected) ?
  #
  # return [Boolean] true, if active / false otherwise
  def connected?
    self.is_connected
  end

 # Disconnect connection, if connected
 #
 # return [Boolean] true, if disconnected a connection / false, if nothing to do
  def disconnect!
    return false unless connected?

    self.is_connected    = false
    self.disconnected_at = Time.now
    self.save

    true
  end

end
