module <%= Rails::Generators.namespace.name if Rails::Generators.namespace.present? %>Domain
  class <%= class_name %> < ActiveRecord::Base
    self.table_name = '<%=table_name %>'
  end
end
