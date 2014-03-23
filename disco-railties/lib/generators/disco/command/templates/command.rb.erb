<% module_namespacing do -%>
class <%= class_name %>Command
  <%- unless skip_model? -%>
  include ActiveModel::Model
  <%- end -%>
  include ActiveEvent::Command
  attributes <%= (['id'] + attributes_names).map{|x| ":#{x}"}.join(', ') %>
  <%- if !model_name.blank? && !skip_model? -%>

  def self.model_name
    @_model_name ||= begin
      namespace = self.parents.detect do |n|
        n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
      end
      ActiveModel::Name.new(self, namespace, <%= model_name.inspect %>)
    end
  end
  <%- end -%>
  <%- if persisted? && ! skip_model? -%>

  def persisted?; true end
  <%- end -%>
end
<% end -%>
