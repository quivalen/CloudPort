class ConnectionWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }

  def perform
    Container.all.each do |c|
      c.synchronize_connections!
    end
  end
end
