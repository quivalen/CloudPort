require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  test "should not be empty" do
    refute_empty Container.all
  end

  test "one-to-one mapping between containers and builds" do
    builds      = Build.all
    containers  = Container.all

    assert_equal builds.map { |b| b.id }.sort, containers.map { |c| c.build_id }.sort
  end

  test "each container should have valid Docker container ID" do
    Container.all.each do |c|
      assert_equal 64, c.docker_container_id.length
    end
  end

  test "each container should have valid IP address" do
    Container.all.each do |c|
      assert_match IP_ADDR_REGEX, c.ip_address
    end
  end

end
