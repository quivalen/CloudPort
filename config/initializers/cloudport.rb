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
  Container.all.each { |c| c.docker_container.start }
end
