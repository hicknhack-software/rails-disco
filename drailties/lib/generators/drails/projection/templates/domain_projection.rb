module <%=if Rails::Generators.namespace.present? then Rails::Generators.namespace.name end%>Domain
  class <%= plural_name.camelcase %>Projection
    include ActiveDomain::Projection
    <% events.each do |event| %>
    def <%=event.underscore%>(event)
    end
    <% end %>
  end
end
