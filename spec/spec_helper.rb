# frozen_string_literal: true

RSpec.configure do |config|
  # rspec-expectations config goes here.
  config.expect_with :rspec do |expectations|
  end

  # rspec-mocks config goes here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that doesn't exist.
    mocks.verify_partial_doubles = true
  end

  # Limit a spec run to individual examples or groups by with `:focus`
  config.filter_run_when_matching :focus

  # Print the slowest examples and example groups at the end of the spec run
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. You can fix the
  # order by providing the seed.
  #     --seed 1234
  config.order = :random
end
