<% module_namespacing do -%>
class <%= plural_name.camelcase %>Projection
  include ActiveProjection::ProjectionType
  <% events.each do |event| %>
      def <%=event.underscore%>(event)
      end
  <% end %>
end
<% end -%>
