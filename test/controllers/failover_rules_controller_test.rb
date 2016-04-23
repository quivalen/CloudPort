require 'test_helper'

class FailoverRulesControllerTest < ActionController::TestCase

  test "valid request creates rule" do
    post :create, { id: Build.last.ptu_build_id }

    assert_response :success
    
    assert_not_nil assigns(:container)
    assert_not_nil assigns(:failover_rule)
  end

  test "invalid request does not create rule" do
    post :create, { id: 'xyeta1' }

    assert_response :not_found
  end

end
