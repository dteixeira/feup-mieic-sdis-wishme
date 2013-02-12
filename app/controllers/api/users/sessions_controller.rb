class Api::Users::SessionsController < Api::BaseApiController

  before_filter :ensure_api_access, :only => [:destroy]
  before_filter :check_valid_login, :only => [:create]

  def create
    login @user
  end

  def destroy
    logout @user
  end

end
