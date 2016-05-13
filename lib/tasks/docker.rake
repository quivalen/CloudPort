#
# Usage:
# * rake docker:containers:recreate - ensure we run clean, just created containers
#
namespace :docker do

  namespace :containers do

    task recreate: :environment do
      return if Rails.env.production? # c'mon don't be loco!

      Docker::Container.all(
            all: true,
        filters: { label: ["environment=#{Rails.env}"] }.to_json,
      ).each do |dc|
        dc.delete(force: true)
      end

      Container.all.each { |c| c.recreate_docker_container! }
    end

  end

end
