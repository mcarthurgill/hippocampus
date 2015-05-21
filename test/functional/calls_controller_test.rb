require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  setup do
    @call = calls(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create call" do
    assert_difference('Call.count') do
      post :create, call: { AccountSid: @call.AccountSid, ApiVersion: @call.ApiVersion, CallSid: @call.CallSid, CallStatus: @call.CallStatus, Called: @call.Called, CalledCity: @call.CalledCity, CalledCountry: @call.CalledCountry, CalledState: @call.CalledState, CalledZip: @call.CalledZip, Caller: @call.Caller, CallerCity: @call.CallerCity, CallerCountry: @call.CallerCountry, CallerState: @call.CallerState, CallerZip: @call.CallerZip, Direction: @call.Direction, From: @call.From, FromCity: @call.FromCity, FromCountry: @call.FromCountry, FromState: @call.FromState, FromZip: @call.FromZip, To: @call.To, ToCity: @call.ToCity, ToCountry: @call.ToCountry, ToState: @call.ToState, ToZip: @call.ToZip }
    end

    assert_redirected_to call_path(assigns(:call))
  end

  test "should show call" do
    get :show, id: @call
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @call
    assert_response :success
  end

  test "should update call" do
    put :update, id: @call, call: { AccountSid: @call.AccountSid, ApiVersion: @call.ApiVersion, CallSid: @call.CallSid, CallStatus: @call.CallStatus, Called: @call.Called, CalledCity: @call.CalledCity, CalledCountry: @call.CalledCountry, CalledState: @call.CalledState, CalledZip: @call.CalledZip, Caller: @call.Caller, CallerCity: @call.CallerCity, CallerCountry: @call.CallerCountry, CallerState: @call.CallerState, CallerZip: @call.CallerZip, Direction: @call.Direction, From: @call.From, FromCity: @call.FromCity, FromCountry: @call.FromCountry, FromState: @call.FromState, FromZip: @call.FromZip, To: @call.To, ToCity: @call.ToCity, ToCountry: @call.ToCountry, ToState: @call.ToState, ToZip: @call.ToZip }
    assert_redirected_to call_path(assigns(:call))
  end

  test "should destroy call" do
    assert_difference('Call.count', -1) do
      delete :destroy, id: @call
    end

    assert_redirected_to calls_path
  end
end
