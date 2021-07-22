class Users::SamlSessionsController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token 
  prepend_before_action :require_no_authentication

  def sson
    redirect_to url_nias(:login), turbolinks:false
  end

  def auth
    nias_sign_in params
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
      @user = User.first_or_initialize_for_nias(params)
      
      logger.debug "USER >> #{@user}"
      logger.debug "PERSISTED >> #{@user.persisted?}"

      if @user.persisted?
        sign_in :user, @user
        redirect_to welcome_path, notice: "Uspješno ste prijavljeni putem sustava NIAS!"
      else
        redirect_to welcome_path, notice: "Pogreška prilikom prijave!"
      end
    end

    def nias_sign_out(status)
      logger.debug "CURRENT USER >> #{current_user}"
      logger.debug "params >> #{params}"

      if status
        sign_out current_user
        redirect_to welcome_path, notice: "Uspješno ste odjavljeni!"
      else
        redirect_to welcome_path, notice: "Odjava je zaustavljena."
      end
    end
end
