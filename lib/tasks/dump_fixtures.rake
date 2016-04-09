#
# Usage:
# * rake db:fixtures:dump to dump all models.
# * rake db:fixtures:dump MODELS="user billing_account" to dump only User and BillingAccount models.
#
namespace :db do

  namespace :fixtures do

    def all_models
      ActiveRecord::Base.subclasses
    end

    def selected_models
      return nil unless ENV['MODELS']

      selected_model_names = ENV['MODELS'].split(/\s+|,/).map(&:camelcase)

      all_models.select { |m| selected_model_names.include?(m.name) }
    end

    desc "Dump fixtures from the current environment's database"
    task dump: :environment do
      Rails.application.eager_load!

      models = selected_models || all_models

      models.each do |model|
        file_name = "#{Rails.root}/test/fixtures/#{model.name.downcase.pluralize}.yml"

        puts "Dumping: #{model.name} => #{file_name}"

        File.open(file_name, 'w') do |file|
          data = {}

          model.all.map(&:attributes).each do |record|
            data["#{model.name.downcase}_#{record['id'].to_s}"] = record
          end

          file.write data.to_yaml
        end
      end
    end

  end

end
