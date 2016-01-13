Docker::Image.create('fromImage' => Build::DOCKER_IMAGE)

Build.all.each { |b| b.docker_container.start }
