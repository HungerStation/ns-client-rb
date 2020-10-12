# simplecov
require 'simplecov'
require 'simplecov-console'

SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start
SimpleCov.minimum_coverage(100)

require "bundler/setup"
require "ns_client"

RSpec.configure do |config|
  config.after(:suite) do
    example_group = RSpec.describe('Code coverage')
    example = example_group.example('must be 100%'){
      expect( SimpleCov.result.covered_percent ).to eq 100
    }
    example_group.run
    passed = example.execution_result.status == :passed
    RSpec.configuration.reporter.example_failed example unless passed
  end if ENV['COVERAGE']
  
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
