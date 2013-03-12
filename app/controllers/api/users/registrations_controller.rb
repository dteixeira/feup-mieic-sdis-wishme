#encoding: UTF-8
class Api::Users::RegistrationsController < Api::BaseApiController

  respond_to :json
  before_filter :check_valid_registration

  def create
    register_user @user
  end

end
