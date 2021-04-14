class Users::SamlSessionsController < Devise::SamlSessionsController
  
  def sso
    request = OneLogin::RubySaml::Authrequest.new
    params = { RelayState: SecureRandom.alphanumeric } 
    private_key
    action = request.create(saml_config, params)
    redirect_to action
  end

  def auth
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_config)
    
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
      path = "#{Rails.root}#{Rails.application.secrets.nias_private_key}"
      pass_phrase = "#{Rails.application.secrets.nias_pass_phrase}"
      private_key = OpenSSL::PKey::RSA.new(File.binread(path), pass_phrase)
      saml_config.private_key = private_key.to_s
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
