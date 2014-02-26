<% if namespaced? -%>
require_dependency '<%= namespaced_file_path %>/application_controller'

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_event_id, only: [:index, :show]

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
  end

  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, 'params[:id]') %>
  end

  def new
    @<%= singular_table_name %> = <%= command_class_name('create') %>Command.new(<%= singular_table_name %>_params)
  end

  def edit
    @<%= singular_table_name %> = <%= command_class_name('update') %>Command.new(<%= orm_class.find(class_name, 'params[:id]') %>.attributes.merge(<%= singular_table_name %>_params))
  end

  def create
    @<%= singular_table_name %> = <%= command_class_name('create') %>Command.new(<%= singular_table_name %>_params)
    if @<%= singular_table_name %>.valid? && (session[:tmp_event_id] = Domain.run_command(@<%= singular_table_name %>))
      redirect_to @<%= singular_table_name %>, notice: <%= "'#{human_name} was successfully created.'" %>
    else
      render action: 'new'
    end
  end

  def update
    @<%= singular_table_name %> = <%= command_class_name('update') %>Command.new(<%= singular_table_name %>_params.merge(id: params[:id]))
    if @<%= singular_table_name %>.valid? && (session[:tmp_event_id] = Domain.run_command(@<%= singular_table_name %>))
      redirect_to @<%= singular_table_name %>, notice: <%= "'#{human_name} was successfully updated.'" %>
    else
      render action: 'edit'
    end
  end

  def destroy
    delete_<%= singular_table_name %> = <%= command_class_name('delete') %>Command.new(id: params[:id])
    session[:tmp_event_id] = event_id = Domain.run_command(delete_<%= singular_table_name %>)
    if event_id
      redirect_to <%= index_helper %>_url, notice: <%= "'#{human_name} was successfully destroyed.'" %>
    else
      redirect_to <%= singular_table_name %>_url(id: params[:id]), error: <%= "'#{human_name} could not be deleted.'" %>
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

  def set_event_id
    @event_id = session[:tmp_event_id]
    session[:tmp_event_id] = nil
  end
end
<% end -%>
