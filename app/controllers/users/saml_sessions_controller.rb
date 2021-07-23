class Users::SamlSessionsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  prepend_before_action :require_no_authentication, only: [:sson, :auth]
  prepend_before_action :allow_params_authentication!, only: :auth

  def sson
    redirect_to url_nias(:login), turbolinks:false
  end

  def auth
    nias_sign_in nias_params
  end
  
  def ssout
    redirect_to url_nias(:logout), turbolinks:false
  end

  def destroy
    nias_sign_out params
  end 

  private

    def url_nias(action)
      url = "http://#{request.host_with_port}:8080/NiasIntegrationTest"

      case action
      when :login
        url << "/loginNiasRequest";
      when :logout
        url << "/logoutNiasRequest" 
      end

      url
    end

    def nias_sign_in(params)
      @user =  User.first_or_initialize_for_nias(params)

      if @user.persisted?
        warden.set_user(@user, scope: resource_name)
        sign_in_and_redirect current_user, event: :authentication
      else
        redirect_to root_path, notice: "Pogreška prilikom prijave!"
      end
    end

    def nias_sign_out(status)
      logger.debug "CURRENT USER >> #{current_user}"
      logger.debug "STATUS >> #{status}"

      if status
        sign_out current_user
        redirect_to root_path, notice: "Uspješno ste odjavljeni!"
      else
        redirect_to root_path, notice: "Odjava je zaustavljena."
      end
    end

    def nias_params
      params.permit(:ime, :prezime, :oib, :tid, :sessionIndex, :subjectId, :subjectIdFormat)
      username = ('a'..'z').to_a.shuffle[0,8].join
      password = Devise.friendly_token[0, 20]
      params.merge(:locale => "hr", :username => username, :email => username+"@example.com", 
        :password => password, :password_confirmation => password, :terms_of_service => 1)
    end
end
