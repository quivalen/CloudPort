require 'test_helper'

class ConnectionTest < ActiveSupport::TestCase
  DUMMY_IP = '4.3.2.1'

  test "created connection is active" do
    connection = Connection.create(remote: DUMMY_IP)

    assert connection.active?
  end

  test "disconnected connection is NOT active" do
    connection = Connection.create(remote: DUMMY_IP)
    connection.disconnect!

    refute connection.active?
  end

  test "by-default connection is direct" do
    connection = Connection.create(remote: DUMMY_IP)

    assert connection.direct?
    refute connection.forwarded?
  end

  test "forwarded connection is correctly detected" do
    connection = Connection.create(remote: DUMMY_IP, is_forwarded: true)

    assert connection.forwarded?
    refute connection.direct?
  end
end
