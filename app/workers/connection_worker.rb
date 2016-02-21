class ConnectionWorker

  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { secondly(15) }

  def perform
    Container.all.each do |c|
      c.synchronize_connections!
    end
  end

end
