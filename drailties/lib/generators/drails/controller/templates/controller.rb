<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, only: [:show, :edit]

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
  end

  def show
  end

  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
  end

  def edit
  end

  def create
    <%= singular_table_name %> = <%= "#{human_name}"%>CreateCommand.new({<%= params_string %>})
    valid = <%= singular_table_name %>.valid?
    if valid and Domain.run_command <%= singular_table_name %>
      flash[:notice] = <%= "'#{human_name} was successfully created.'" %>
      redirect_to action: :index
    else
      flash[:error] = <%= "'#{human_name} couldn\\'t be created.'" %>
      redirect_to action: :new
    end
  end

  def update
    <%= singular_table_name %> = <%= "#{human_name}"%>UpdateCommand.new({id: params[:id]<%=',' unless params_string == ''%> <%= params_string %>})
    valid = <%= singular_table_name %>.valid?
    if valid and Domain.run_command <%= singular_table_name %>
      flash[:notice] = <%= "'#{human_name} was successfully updated.'" %>
      redirect_to action: :show, id: params[:id]
    else
      flash[:error] = <%= "'#{human_name} couldn\\'t be updated.'" %>
      redirect_to action: :edit, id: params[:id]
    end
  end

  def destroy
    <%= singular_table_name %> = <%= "#{human_name}"%>DeleteCommand.new({id: params[:id]})
    if Domain.run_command <%= singular_table_name %>
      flash[:notice] = <%= "'#{human_name} was successfully deleted.'" %>
    else
      flash[:error] = <%= "'#{human_name} couldn\\'t be deleted.'" %>
    end
    redirect_to action: :index
  end

  private
  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end
end
<% end -%>
