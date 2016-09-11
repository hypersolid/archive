module ControllerHelpers
  def setup_controller_stubs
    @controller.stub(:current_tournament).and_return(Factory(:tournament))
    @controller.stub(:authenticate_user!)
  end

  def login_admin
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in FactoryGirl.create(:admin_user)
  end

  def login_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
  end
end
