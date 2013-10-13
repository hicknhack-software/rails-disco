module <%=if Rails::Generators.namespace.present? then Rails::Generators.namespace.name end%>Domain
  class <%= class_name %>Projection
    include ActiveDomain::Projection
    <% events.each do |event| %>
    def <%= event.underscore.split('/') * '__' %>(event)
    end
    <% end %>
  end
end
