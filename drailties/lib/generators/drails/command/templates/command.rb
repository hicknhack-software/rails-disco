<% module_namespacing do -%>class <%= class_name %>Command
  include ActiveEvent::Command
  attributes :id<%=',' unless attributes_names.empty? %> <%=attributes_names.map{|x| ":#{x}"}.join(', ')%>
end
<% end -%>