<% if namespaced? -%>
require_dependency '<%= namespaced_file_path %>/application_controller'

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  include EventSource

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
  end

  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, 'id_param') %>
  end

  def new
    @<%= singular_table_name %> = <%= command_class_name('create') %>Command.new
  end

  def edit
    @<%= singular_table_name %> = <%= command_class_name('update') %>Command.new <%= orm_class.find(class_name, 'id_param') %>.attributes
  end

  def create
    @<%= singular_table_name %> = <%= command_class_name('create') %>Command.new <%= singular_table_name %>_params
    if store_event_id Domain.run_command(@<%= singular_table_name %>)
      redirect_to @<%= singular_table_name %>, notice: <%= "'#{human_name} was successfully created.'" %>
    else
      render action: 'new'
    end
  end

  def update
    @<%= singular_table_name %> = <%= command_class_name('update') %>Command.new <%= singular_table_name %>_params.merge(id: id_param)
    if store_event_id Domain.run_command(@<%= singular_table_name %>)
      redirect_to @<%= singular_table_name %>, notice: <%= "'#{human_name} was successfully updated.'" %>
    else
      render action: 'edit'
    end
  end

  def destroy
    delete_<%= singular_table_name %> = <%= command_class_name('delete') %>Command.new(id: id_param)
    if store_event_id Domain.run_command(delete_<%= singular_table_name %>)
      redirect_to <%= index_helper %>_url, notice: <%= "'#{human_name} was successfully destroyed.'" %>
    else
      redirect_to <%= singular_table_name %>_url(id: id_param), alert: <%= "'#{human_name} could not be deleted.'" %>
    end
  end

  private

  def <%= "#{singular_table_name}_params" %>
    <%- if attributes_names.empty? -%>
        params[<%= ":#{singular_table_name}" %>]
    <%- else -%>
    params.require(<%= ":#{singular_table_name}" %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
    <%- end -%>
  end

  def id_param
    params.require(:id).to_i
  end
end
<% end -%>
