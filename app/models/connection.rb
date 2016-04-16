class Connection < ActiveRecord::Base

  ZERO_TIMESTAMP  = '0000-01-01 00:00:00'.to_datetime

  belongs_to :container

  validates :remote,
    presence: true,
    uniqueness: true,
    format: { with: IP_PORT_REGEX }

  scope :active,    -> { where(is_connected: true) }
  scope :direct,    -> { where(is_connected: true, is_forwarded: false) }
  scope :forwarded, -> { where(is_connected: true, is_forwarded: true) }

  def initialize(remote:, is_forwarded: false)
    super

    self.connected_at     = Time.now
    self.disconnected_at  = ZERO_TIMESTAMP
  end

  # Is connection active (connected) ?
  #
  # return [Boolean] true, if active / false otherwise
  def active?
    self.is_connected
  end

  # Is connection direct (p.t.u. connected) ?
  #
  # return [Boolean] true, if direct / false otherwise
  def direct?
    !self.is_forwarded
  end

  # Is connection forwarded (connected over established p.t.u. tunnel) ?
  #
  # return [Boolean] true, if forwarded / false otherwise
  def forwarded?
    self.is_forwarded
  end

 # Disconnect connection, if connected
 #
 # return [Boolean] true, if disconnected a connection / false, if nothing to do
  def disconnect!
    return false unless active?

    self.is_connected    = false
    self.disconnected_at = Time.now
    self.save

    true
  end

end
