require 'test_helper'

class MeshesControllerTest < ActionController::TestCase
  setup do
    @mesh = meshes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:meshes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mesh" do
    assert_difference('Mesh.count') do
      post :create, mesh: { name: @mesh.name }
    end

    assert_redirected_to mesh_path(assigns(:mesh))
  end

  test "should show mesh" do
    get :show, id: @mesh
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mesh
    assert_response :success
  end

  test "should update mesh" do
    patch :update, id: @mesh, mesh: { name: @mesh.name }
    assert_redirected_to mesh_path(assigns(:mesh))
  end

  test "should destroy mesh" do
    assert_difference('Mesh.count', -1) do
      delete :destroy, id: @mesh
    end

    assert_redirected_to meshes_path
  end
end
