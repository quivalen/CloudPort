Docker::Image.create('fromImage' => Build::DOCKER_IMAGE)

Docker::Container.all.each { |c| c.start }
