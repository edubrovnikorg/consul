class Users::SamlSessionsController < Devise::SamlSessionsController

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
