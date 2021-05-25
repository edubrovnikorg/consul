class Users::SamlSessionsController < Devise::SessionsController
  prepend_before_action :require_no_authentication, only: :sso
  before_action :saml_settings

  def sso
    request = OneLogin::RubySaml::Authrequest.new
    params = { RelayState: SecureRandom.alphanumeric } 
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
    def saml_settings
      key = "#{Rails.application.credentials.nias_demo[:private_key]}"
      pass_phrase = "#{Rails.application.credentials[:nias_passphrase]}"
      private_key = OpenSSL::PKey::RSA.new(key, pass_phrase)

      settings = OneLogin::RubySaml::Settings.new
      settings.idp_sso_service_url                = "https://niastst.fina.hr/sso-http"
      settings.protocol_binding                   = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
      settings.assertion_consumer_service_url     = "#{request.protocol}#{request.host_with_port}/users/nias/auth"
      settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
      settings.issuer                             = "#{Rails.application.credentials[:nias_issuer]}"
      settings.name_identifier_format             = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
      settings.authn_context                      = ""
      settings.idp_sso_target_url                 = "https://niastst.fina.hr/sso-http"
      settings.idp_cert                           = "#{Rails.application.credentials.nias_demo[:cert]}"
      settings.private_key                        = "#{Rails.application.credentials.nias_demo[:key]}"
      settings.compress_request                   = true
      settings.security[:authn_requests_signed]   = true
      settings.security[:embed_sign]              = false
      settings.security[:signature_method]        = XMLSecurity::Document::RSA_SHA256
      settings.double_quote_xml_attribute_values  = true
      settings.private_key = private_key.to_s
      
      return settings
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
