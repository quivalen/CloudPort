class Connection < ActiveRecord::Base

  belongs_to :build

  ZERO_TIMESTAMP = '0000-01-01 00:00:00'.to_datetime

  def initialize(build:, remote:)
    super

    self.connected_at     = Time.now
    self.disconnected_at  = ZERO_TIMESTAMP
  end

  def connected?
    self.disconnected_at == ZERO_TIMESTAMP
  end

  def disconnect!
    self.disconnected_at = Time.now
    self.save
  end

end
