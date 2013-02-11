class Api::RegistrationsController < Api::BaseApiController

  respond_to :json
  before_filter :check_valid_registration

  def create
    register_user @user
  end

end
