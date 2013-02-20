module Api::Users::SessionsHelper

  FB_URI = 'https://graph.facebook.com/me?access_token='

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

  def check_valid_login_fb
    begin
      url = URI.parse "#{FB_URI + params[:user][:fb_token]}"
      resp = JSON.parse(Net::HTTP.start(url.host, url.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.get url.request_uri
      end.body)
      return sessions_failure I18n.t('sessions.failure.invalid_fb_login') unless resp["error"].blank?
      @user = User.find_for_database_authentication(:email => resp["email"])
      if not @user
        username = nil
        begin token = SecureRandom.urlsafe_base64(6) end while
          User.where(:username => token).exists? username = token
        @user = User.create!(:email => resp["email"], :password => Devise.friendly_token[0, 8], :username => username)
      end
    rescue
      return sessions_failure I18n.t('sessions.failure.invalid_fb_login')
    end
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
