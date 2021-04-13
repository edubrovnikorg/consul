class Users::SamlSessionsController < Devise::SamlSessionsController

  def new
    request = OneLogin::RubySaml::Authrequest.new
    params = { RelayState: SecureRandom.alphanumeric } 
    action = request.create(saml_config, params)
    redirect_to action
  end

  def auth
    byebug

    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_config)
  end

  def after_sign_in(resource)
    if authorize_mup resource
      sign_in_and_redirect current_user, event: :authentication
    else
      sign_out current_user
      redirect_to welcome_path, notice: "Pogreška pri logiranju!"
    end
  end
  
  private

    # def nias_sign_in
    #   @user = User.first_or_initialize_for_nias(sign_up_params)

    #   if @user.save
    #     sign_in_and_redirect current_user, event: :authentication
    #   else
    #     redirect_to welcome_path, notice: "Pogreška pri logiranju!"
    #   end
    # end
end
