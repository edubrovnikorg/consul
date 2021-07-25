class Users::SamlSessionsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  prepend_before_action :authenticate_user!, only: [:ssout, :destroy]
  prepend_before_action :allow_params_authentication!, only: :auth

  def sson
    redirect_to url_nias(:login), turbolinks:false
  end

  def auth
    logger.debug current_user
    self.resource = User.first_or_initialize_for_nias(nias_params)
    redirect_to :action => 'finish_sign_up', resource: resource
  end
  
  def ssout
    redirect_to url_nias(:logout), turbolinks:false
  end

  def finish_sign_up
    logger.debug "RESOURCE>> #{resource}"
    logger.debug "CURRENT USER>> #{current_user}"
    resource = User.find_by(id: params[:resource])
    logger.debug "RESOURCE USER>> #{resource}"
    logger.debug "PARAMS>> #{params}"

    sign_in_and_redirect resource, event: :authentication
    set_flash_message(:notice, :success, kind: :nias.to_s.capitalize) if is_navigational_format?
  #   if sign_up(resource_name, resource)
  #     redirect_to root_path, notice: "Uspješno ste prijavljeni!"
  #   else
  #     redirect_to root_path, notice: "Greška prilikom prijave!"
  #   end
  end

  def destroy
    nias_sign_out params
  end 

  private

    def url_nias(action)
      url = "http://#{request.host_with_port}:8080/NiasIntegrationTestV2"

      case action
      when :login
        url << "/loginNiasRequest";
      when :logout
        url << "/logoutNiasRequest" 
      end

      url
    end

    # def nias_sign_in(params)
    #   self.resource = warden.authenticate!(auth_options)
    #   sign_in(resource)
    #   self.resource =  User.first_or_initialize_for_nias(params)

    #   if resource.persisted?
    #     redirect_to :action => 'post_sign_up'
    #   else
    #     redirect_to root_path, notice: "Pogreška prilikom prijave!"
    #   end
    # end

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
      params.require([:ime, :prezime, :oib, :tid, :sessionIndex, :subjectId, :subjectIdFormat])
      username = ('a'..'z').to_a.shuffle[0,8].join
      password = Devise.friendly_token[0, 20]
      params.merge(:locale => "hr", :username => username, :email => username+"@example.com", 
        :password => password, :password_confirmation => password, :terms_of_service => 1)
    end
end
