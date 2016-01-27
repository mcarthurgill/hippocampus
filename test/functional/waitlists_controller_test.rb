require 'test_helper'

class WaitlistsControllerTest < ActionController::TestCase
  setup do
    @waitlist = waitlists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:waitlists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create waitlist" do
    assert_difference('Waitlist.count') do
      post :create, waitlist: { email: @waitlist.email }
    end

    assert_redirected_to waitlist_path(assigns(:waitlist))
  end

  test "should show waitlist" do
    get :show, id: @waitlist
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @waitlist
    assert_response :success
  end

  test "should update waitlist" do
    put :update, id: @waitlist, waitlist: { email: @waitlist.email }
    assert_redirected_to waitlist_path(assigns(:waitlist))
  end

  test "should destroy waitlist" do
    assert_difference('Waitlist.count', -1) do
      delete :destroy, id: @waitlist
    end

    assert_redirected_to waitlists_path
  end
end
