module <%= Rails::Generators.namespace.name if Rails::Generators.namespace.present? %>Domain
  class <%= class_name %>Projection
    include ActiveDomain::Projection
    <% events.each do |event| %>
    def <%= event.underscore.split('/') * '__' %>(event)
    end
    <% end %>
  end
end
