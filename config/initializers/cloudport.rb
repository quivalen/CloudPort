#
# Ensure CloudPort build root path created
#
unless Dir.exist?(CloudPort::Application.config.build_root)
  FileUtils.mkdir_p(CloudPort::Application.config.build_root)
end

#
# Ensure required Docker image pulled
#
Docker::Image.create(
  'fromImage' => CloudPort::Application.config.docker_image
)

#
# Start Docker containers for all builds
#
# Note: We check for `builds` table existence,
# cause we don't want to fail 'db:schema:load'
# during initial provisioning of application!
#
if ActiveRecord::Base.connection.table_exists?(:builds)
  Build.all.each do |b|
    begin
      b.docker_container.start
    rescue => e
      Rails.logger.error("Failed to start container: #{e.message}")
    end
  end
end
