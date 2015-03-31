require 'test_helper'

class ContactCardsControllerTest < ActionController::TestCase
  setup do
    @contact_card = contact_cards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contact_cards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contact_card" do
    assert_difference('ContactCard.count') do
      post :create, contact_card: { bucket_id: @contact_card.bucket_id, contact_info: @contact_card.contact_info }
    end

    assert_redirected_to contact_card_path(assigns(:contact_card))
  end

  test "should show contact_card" do
    get :show, id: @contact_card
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contact_card
    assert_response :success
  end

  test "should update contact_card" do
    put :update, id: @contact_card, contact_card: { bucket_id: @contact_card.bucket_id, contact_info: @contact_card.contact_info }
    assert_redirected_to contact_card_path(assigns(:contact_card))
  end

  test "should destroy contact_card" do
    assert_difference('ContactCard.count', -1) do
      delete :destroy, id: @contact_card
    end

    assert_redirected_to contact_cards_path
  end
end
