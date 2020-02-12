require "bundler/setup"
require "rspec/matchers"
require "equivalent-xml"
require "vcr"
require 'simplecov'

VCR.configure do |conf|
  conf.cassette_library_dir = "spec/vcr_cassettes"
  conf.hook_into :webmock
end

SimpleCov.start do
  add_filter '/spec/'
end

require "relaton_omg"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
