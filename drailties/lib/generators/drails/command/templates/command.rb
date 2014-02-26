<% module_namespacing do -%>
class <%= class_name %>Command
  <%- unless skip_model? -%>
  include ActiveModel::Model
  <%- end -%>
  include ActiveEvent::Command
  attributes <%= (['id'] + attributes_names).map{|x| ":#{x}"}.join(', ') %>
end
<% end -%>
