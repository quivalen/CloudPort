#
# Ensure CloudPort build root path created
#
unless Dir.exist?(CloudPort::Application.config.build_root)
  FileUtils.mkdir_p(CloudPort::Application.config.build_root)
end

#
# Start [Docker] containers, if ordered to
#
if ENV['START_CONTAINERS']
  Container.where(is_failed: false).each do |c|
    begin
      c.docker_container.start
    rescue => e
      c.is_failed       = true
      c.failure_message = e.message
      c.save
    end
  end
end
