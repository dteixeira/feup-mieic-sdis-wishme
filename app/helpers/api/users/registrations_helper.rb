module Api::Users::RegistrationsHelper

  def check_valid_registration
    begin
      treat_params
      resource = User.find_for_database_authentication(:email => params[:user][:email])
      return registration_failure I18n.t('registrations.failure.email') if resource
      resource = User.find_for_database_authentication(:username => params[:user][:username])
      return registration_failure I18n.t('registrations.failure.username') if resource
      params[:user][:password]
      @user = User.new params[:user]
    rescue
      return registration_failure I18n.t('registrations.failure.missing')
    end
  end

  def register_user user
    begin
      user.save!
      @user = user
      return registration_success
    rescue
      return registration_failure I18n.t('registrations.failure.bad_params')
    end
  end

  private

  def registration_success
    render :json => {
      :success => true,
      :email => @user.email,
      :username => @user.username,
      :authentication_token => @user.authentication_token
    }
  end

  def registration_failure msg
    render :json => {
      :success => false,
      :message => msg
    }
  end

  def treat_params
    params[:user][:email].downcase!
    params[:user][:username].downcase!
  end

end
