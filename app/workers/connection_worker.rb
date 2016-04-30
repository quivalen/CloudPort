class ConnectionWorker

  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { secondly(15) }

  def perform
    Container.all.each do |c|
      begin
        c.synchronize_connections!
      rescue => e
        Rails.logger.error(
          ">>> Failed to synchronize connections state "\
          "for Docker container [#{c.docker_container_id}]:\n"\
          "* #{e.message}"
        )
      end
    end
  end

end
