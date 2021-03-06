# frozen_string_literal: true

require 'cucumber/blendle/helpers/liquid_filters'

require 'cucumber/blendle/support/cucumber'
require 'cucumber/blendle/support/dump'
require 'cucumber/blendle/support/hyper_resource'
require 'cucumber/blendle/support/json_spec'
require 'cucumber/blendle/support/minitest'
require 'cucumber/blendle/support/rack_test'

require 'cucumber/blendle/steps/benchmark_steps'
require 'cucumber/blendle/steps/debug_steps'
require 'cucumber/blendle/steps/mock_server_steps'
require 'cucumber/blendle/steps/model_steps'
require 'cucumber/blendle/steps/resource_steps'
require 'cucumber/blendle/steps/rest_steps'

module Cucumber
  module BlendleSteps
    class << self
      attr_accessor :model_prefix
    end
  end
end

Cucumber::BlendleSteps.model_prefix = '' # Default to empty prefix
