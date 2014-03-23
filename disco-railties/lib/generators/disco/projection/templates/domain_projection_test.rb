require 'test_helper'

module <%= Rails::Generators.namespace.name if Rails::Generators.namespace.present? %>Domain
  class <%= plural_name.camelcase %>ProjectionTest < ActiveSupport::TestCase
  end
end
