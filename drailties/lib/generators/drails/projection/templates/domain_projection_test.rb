require 'test_helper'

module <%=if Rails::Generators.namespace.present? then Rails::Generators.namespace.name end%>Domain
  class <%= plural_name.camelcase %>ProjectionTest < ActiveSupport::TestCase
  end
end
