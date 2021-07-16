class Users::SamlSessionsController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token 
  prepend_before_action :require_no_authentication

  def sso
    redirect_to nias_login, turbolinks:false
  end

  def auth
    logger.debug "============================== SAML RESPONSE ===================================="
    logger.debug "RESPONSE >> #{params[:saml_session]}"
    logger.debug "============================== SAML RESPONSE ===================================="
    nias_sign_in params[:saml_session]
  end
  
  private
    def nias_login
      "#{request.protocol}#{request.host_with_port}/NiasIntegrationTest/loginNiasRequest";
    end
    
    def nias_sign_in(params)
      @user = User.first_or_initialize_for_nias(params)
      @user[:approved] = true;
   
      if @user.save
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, :kind => "NIAS Login") if is_navigational_format?
      else
        redirect_to welcome_path, notice: "Pogreška pri logiranju!"
      end
    end
end
