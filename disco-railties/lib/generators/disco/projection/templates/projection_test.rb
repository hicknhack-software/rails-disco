require 'test_helper'

<% module_namespacing do -%>
class <%= plural_name.camelcase %>ProjectionTest < ActiveSupport::TestCase
end
<% end -%>
