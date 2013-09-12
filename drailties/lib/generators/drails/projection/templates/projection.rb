<% module_namespacing do -%>
class <%= class_name %>Projection
  include ActiveProjection::ProjectionType
  <% events.each do |event| %>
      def <%=event.underscore%>(event)
      end
  <% end %>
end
<% end -%>
