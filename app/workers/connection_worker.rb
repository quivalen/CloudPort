class ConnectionWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }

  def perform
    Build.all.each do |build|
      build.synchronize_connections!
    end
  end
end
