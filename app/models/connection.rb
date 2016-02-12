class Connection < ActiveRecord::Base

  belongs_to :build

  default_scope { where(is_connected: true) }

  ZERO_TIMESTAMP = '0000-01-01 00:00:00'.to_datetime

  def initialize(build:, remote:)
    super

    self.connected_at     = Time.now
    self.disconnected_at  = ZERO_TIMESTAMP
  end

  def connected?
    self.is_connected
  end

  def disconnect!
    self.is_connected    = false
    self.disconnected_at = Time.now
    self.save
  end

end
