module <%= Rails::Generators.namespace.name if Rails::Generators.namespace.present? %>Domain
  class <%= class_name %>Processor
    include ActiveDomain::CommandProcessor
  end
end
