require 'test_helper'

class BuildTest < ActiveSupport::TestCase
  test "should not be empty" do
    refute_empty Build.all
  end

  test "all existing records should validate" do
    Build.all.each { |b| assert b.valid?, "#{b.class.name}[#{b.id}] is invalid" }
  end

  test "new record should validate" do
    build = Build.new

    assert build.valid?, "#{build.class.name} (#{build.inspect}) is invalid"
  end

  test "new record should be saveable" do
    build = Build.new

    assert build.save, "Unable to save #{build.class.name} (#{build.inspect}):\n\
      #{build.errors.messages}\nSee also: #{build.build_path}"
  end

  test "every existing record should have one container instance" do
    Build.all do |b|
      assert b.container
      assert_kind_of b.container, Container
    end
  end

  test "build should manage its filesystem objects during its lifecycle" do
    build = Build.new

    msg = 'exists before creation:'
    refute Dir.exist?(build.build_path), "#{msg} #{build.build_path}"
    refute File.exist?(build.build_stdout_destination), "#{msg} #{build.build_stdout_destination}"
    refute File.exist?(build.build_stderr_destination), "#{msg} #{build.build_stderr_destination}"
    refute File.exist?(build.build_prepare_log), "#{msg} #{build.build_prepare_log}"

    build.save

    msg = 'does not exist after creation:'
    assert Dir.exist?(build.build_path), "#{msg} #{build.build_path}"
    assert File.exist?(build.build_stdout_destination), "#{msg} #{build.build_stdout_destination}"
    assert File.exist?(build.build_stderr_destination), "#{msg} #{build.build_stderr_destination}"
    assert File.exist?(build.build_prepare_log), "#{msg} #{build.build_prepare_log}"

    refute_equal 0, File.size(build.build_stdout_destination)
    assert_equal 0, File.size(build.build_stderr_destination)
    refute_equal 0, File.size(build.build_prepare_log)

    build.destroy

    msg = 'exists after deletion:'
    refute Dir.exist?(build.build_path), "#{msg} #{build.build_path}"
    refute File.exist?(build.build_stdout_destination), "#{msg} #{build.build_stdout_destination}"
    refute File.exist?(build.build_stderr_destination), "#{msg} #{build.build_stderr_destination}"
    refute File.exist?(build.build_prepare_log), "#{msg} #{build.build_prepare_log}"
  end

  test "build with valid target IP address could be saved" do
    build = Build.new

    build.target_address = '200.100.50.25'
    assert build.save
  end

  test "build with valid target host name could be saved" do
    build = Build.new

    build.target_address = 'dev.ops.com'
    assert build.save
  end

  test "build with invalid target address could NOT be saved" do
    build = Build.new

    build.target_address = 'OlaK.ase'
    refute build.save

    build.target_address = '-fistro.com'
    refute build.save
  end

  test "build with valid target port number could be saved" do
    build = Build.new

    build.target_port = 1 + rand(65535)
    assert build.save
  end

  test "build with invalid target port number could NOT be saved" do
    build = Build.new

    build.target_port = 65535 + rand(1000000)
    refute build.save

    build.target_port = 0 - rand(1000000)
    refute build.save
  end

  test "can build p.t.u. for Linux" do
    build = Build.new

    build.operating_system = 'linux'

    assert build.save
  end

  test "can build p.t.u. for MacOSX" do
    build = Build.new

    build.operating_system = 'darwin'

    assert build.save
  end

  test "can build p.t.u. for Windows" do
    build = Build.new

    build.operating_system = 'windows'

    assert build.save
  end

  test "can NOT build p.t.u. for ReactOS" do
    build = Build.new

    build.operating_system = 'reactos'

    refute build.save
  end
end
