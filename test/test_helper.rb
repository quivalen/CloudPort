ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

def read_file(file)
  IO.read(file)
rescue => e
  "FAILED TO OPEN #{file}: #{e.message}"
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all # we do not need to load fixtures every time, it's a mastrubation!

  # Add more helper methods to be used by all tests here...
end
