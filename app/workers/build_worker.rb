class BuildWorker

  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    Build.where("created_at < ?", 7.days.ago).each do |b|
      b.destroy! if b.connections.empty?
    end

    Build.where("created_at < ?", 28.days.ago).each do |b|
      b.destroy! if b.connections.active.empty?
    end
  end

end
