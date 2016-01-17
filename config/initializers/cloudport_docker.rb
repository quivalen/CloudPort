Docker::Image.create(
  'fromImage' => CloudPort::Application.config.docker_image
)

if ActiveRecord::Base.connection.table_exists?(:builds)
  Build.all.each { |b| b.docker_container.start }
end
