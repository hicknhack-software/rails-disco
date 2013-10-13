<% module_namespacing do -%>
class <%= event_class_name %>Event
  include ActiveEvent::EventType
  attributes :id<%=',' unless attributes_names.empty? %> <%=attributes_names.map{|x| ":#{x}"}.join(', ')%>

  def values
    attributes_except :id
  end
end
<% end -%>