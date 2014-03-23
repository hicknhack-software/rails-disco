require 'test_helper'

<% module_namespacing do -%>
class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  setup do
    @<%= singular_table_name %> = <%= table_name %>(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  #test "should create <%= singular_table_name %>" do
  #  #removed for now, because there is no reason to test the post here, cause the projection creates it
  #  #maybe we could test something else here instead
  #end

  test "should show <%= singular_table_name %>" do
    get :show, id: <%= "@#{singular_table_name}" %>
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: <%= "@#{singular_table_name}" %>
    assert_response :success
  end

  #test "should update <%= singular_table_name %>" do
  #  #removed for now, because there is no reason to test the update here, cause the projection updates it
  #  #maybe we could test something else here instead
  #end

  #test "should destroy <%= singular_table_name %>" do
  #  #removed for now, because there is no reason to test the destroy here, cause the projection destroys it
  #  #maybe we could test something else here instead
  #end
end
<% end -%>
