class Users::SamlSessionsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  prepend_before_action :authenticate_user!, only: [:ssout, :destroy]
  prepend_before_action :allow_params_authentication!, only: :auth

  def index
    @user = get_nias_user
    render :index
    # log_in_with_nias
  end

  def sson
    redirect_to url_nias(:login), turbolinks:false
  end

  def auth
    # warden.authenticate!(:nias_login)
    # @user = User.where(oib: 23457554).first    
    user = User.first_or_initialize_for_nias(nias_params)
    # redirect_to :action => 'index', id: user
    head :no_content 
    # redirect_to nias_index_path(id: user) 
  end
  
  def ssout
    redirect_to url_nias(:logout), turbolinks:false
  end

  def finish_sign_up
    log_in_with_nias
    # redirect_to root_path
    # redirect_to after_sign_in_path_for(resource)
    # sign_in_and_redirect resource, event: :authentication
    # set_flash_message(:notice, :success, kind: :nias.to_s.capitalize) if is_navigational_format?
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
      url = "http://#{request.host_with_port}:8080/NiasIntegrationTest"

      case action
      when :login
        url << "/loginNiasRequest";
      when :logout
        url << "/logoutNiasRequest" 
      end

      url
    end

    def log_in_with_nias
      # warden.authenticate!(:nias_login)
      user = User.find_by(id: params[:id])
      sign_in_and_redirect user, event: :authentication
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

    def get_nias_user
      User.where(session_index: params[:sessionIndex]).where(subject_id: params[:subjectId]).first
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
      params.require([:ime, :prezime, :oib, :tid, :sessionIndex, :subjectId, :subjectIdFormat])
      username = ('a'..'z').to_a.shuffle[0,8].join
      password = Devise.friendly_token[0, 20]
      params.merge(:locale => "hr", :username => username, :email => username+"@example.com", 
        :password => password, :password_confirmation => password, :terms_of_service => 1)
    end
end
