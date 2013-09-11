module <%=if Rails::Generators.namespace.present? then Rails::Generators.namespace.name end%>Domain
  class <%= class_name %>Processor
    include ActiveDomain::CommandProcessor
  end
end