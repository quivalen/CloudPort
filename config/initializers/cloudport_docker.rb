Docker::Image.create('fromImage' => Build::DOCKER_IMAGE)

begin
  Build.all.each { |b| b.docker_container.start }
rescue
end
