module Api::Users::SessionsHelper

  def ensure_api_access
    begin
      resource = User.find_for_database_authentication(:authentication_token => params[:user][:authentication_token])
      return sessions_failure I18n.t('sessions.failure.invalid_api_access') unless resource
      @user = resource
    rescue
      return sessions_failure I18n.t('sessions.failure.missing_invalid')
    end
  end

  def check_valid_login
    begin
      params[:user][:login].downcase!
      resource = User.find_for_database_authentication(:email => params[:user][:login]) ||
        User.find_for_database_authentication(:username => params[:user][:login])
      return sessions_failure I18n.t('sessions.failure.password') unless resource.valid_password? params[:user][:password]
      @user = resource
    rescue
      return sessions_failure I18n.t('sessions.failure.missing_invalid')
    end
  end

  def login user
    user.reset_authentication_token!
    @user = user
    render :json => {
      :success => true,
      :email => @user.email,
      :username => @user.username,
      :authentication_token => user.authentication_token
    }
  end

  def logout user
    user.authentication_token = nil
    user.save!
    render :json => {
      :success => true
    }
  end

  private

  def sessions_failure msg
    render :json => {
      :success => false,
      :message => msg
    }
  end

end
