class Users::SamlSessionsController < Devise::SessionsController
  prepend_before_action :require_no_authentication, only: :sso

  def sso
    request = OneLogin::RubySaml::Authrequest.new
    params = { RelayState: SecureRandom.alphanumeric } 
    private_key
    action = request.create(saml_settings, params)
    redirect_to action, turbolinks: false
  end

  def auth
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_settings)
    logger.debug "============================== SAML RESPONSE ===================================="
    logger.debug "RESPONSE >> #{response}"
    logger.debug "============================== SAML RESPONSE ===================================="
  end

  # def after_sign_in(resource)
  #   if authorize_mup resource
  #     sign_in_and_redirect current_user, event: :authentication
  #   else
  #     sign_out current_user
  #     redirect_to welcome_path, notice: "Pogreška pri logiranju!"
  #   end
  # end
  
  private

    def private_key
      key = "#{Rails.application.credentials.nias_demo[:private_key]}"
      pass_phrase = "#{Rails.application.credentials[:nias_passphrase]}"
      private_key = OpenSSL::PKey::RSA.new(key, pass_phrase)
      saml_settings.private_key = private_key.to_s
    end

    def saml_settings
      Devise.saml_config
    end
    # def nias_sign_in
    #   @user = User.first_or_initialize_for_nias(sign_up_params)

    #   if @user.save
    #     sign_in_and_redirect current_user, event: :authentication
    #   else
    #     redirect_to welcome_path, notice: "Pogreška pri logiranju!"
    #   end
    # end
end
