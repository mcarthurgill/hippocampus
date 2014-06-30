require 'test_helper'

class BucketItemPairsControllerTest < ActionController::TestCase
  setup do
    @bucket_item_pair = bucket_item_pairs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bucket_item_pairs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bucket_item_pair" do
    assert_difference('BucketItemPair.count') do
      post :create, bucket_item_pair: { bucket_id: @bucket_item_pair.bucket_id, item_id: @bucket_item_pair.item_id }
    end

    assert_redirected_to bucket_item_pair_path(assigns(:bucket_item_pair))
  end

  test "should show bucket_item_pair" do
    get :show, id: @bucket_item_pair
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bucket_item_pair
    assert_response :success
  end

  test "should update bucket_item_pair" do
    put :update, id: @bucket_item_pair, bucket_item_pair: { bucket_id: @bucket_item_pair.bucket_id, item_id: @bucket_item_pair.item_id }
    assert_redirected_to bucket_item_pair_path(assigns(:bucket_item_pair))
  end

  test "should destroy bucket_item_pair" do
    assert_difference('BucketItemPair.count', -1) do
      delete :destroy, id: @bucket_item_pair
    end

    assert_redirected_to bucket_item_pairs_path
  end
end
