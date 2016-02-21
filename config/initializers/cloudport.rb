#
# We should know, if we run rake task, scheduler etc.
# HINT: We should skip running most of this initializer code, if we run "em!
#
def running_rake?
  File.basename($0) == 'rake'
end

def skip_docker?
  !!ENV['SKIP_DOCKER']
end

#
# Ensure CloudPort build root path created
#
unless Dir.exist?(CloudPort::Application.config.build_root)
  FileUtils.mkdir_p(CloudPort::Application.config.build_root)
end

#
# Ensure required Docker image pulled
#
unless running_rake? || skip_docker?
  Docker::Image.create('fromImage' => CloudPort::Application.config.docker_image)
end

#
# Start Docker containers for all builds
#
unless running_rake? || skip_docker?
  Container.all.each { |c| c.docker_container.start }
end
