module <%=if Rails::Generators.namespace.present? then Rails::Generators.namespace.name end%>Domain
  class <%= class_name %> < ActiveRecord::Base
    self.table_name = '<%=table_name %>'
  end
end