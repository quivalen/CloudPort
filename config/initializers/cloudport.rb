#
# Ensure CloudPort build root path created
#
unless Dir.exist?(CloudPort::Application.config.build_root)
  FileUtils.mkdir_p(CloudPort::Application.config.build_root)
end

#
# Ensure required Docker image pulled
#
begin
  Docker::Image.create(
    'fromImage' => CloudPort::Application.config.docker_image
  )
rescue => e
  Rails.logger.fatal("Failed to import Docker image: #{e.message}")
end

#
# Start Docker containers for all builds
#
# Note: We check for `builds` table existence,
# cause we don't want to fail 'db:schema:load'
# during initial provisioning of application!
#
if ActiveRecord::Base.connection.table_exists?(:builds)
  begin
    Build.all.each do |b|
      begin
        b.docker_container.start
      rescue => e
        Rails.logger.error("Failed to start container: #{e.message}")
      end
    end
  rescue => e
    rails.logger.fatal("Failed to initialize containers: #{e.message}")
  end
end
