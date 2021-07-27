class Users::SamlSessionsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  prepend_before_action :authenticate_user!, only: [:ssout, :destroy]
  prepend_before_action :allow_params_authentication!, only: :auth

  def show
    @user = get_nias_user
    render :index
  end

  def sson
    redirect_to url_nias(:login), turbolinks:false
  end

  def auth    
    user = User.first_or_initialize_for_nias(nias_params)
    head :no_content 
  end
  
  def ssout
    if current_user
      uri = URI(url_nias(:logout))
      res = Net::HTTP.post_form(uri, 
        'subjectIdFormat' => current_user.subject_id_format,
        'subjectId' => current_user.subject_id,
        'sessionIndex' => 1)
      logger.debug 'HTTP LOGOUT POST'
      puts res.body  if res.is_a?(Net::HTTPSuccess)
    else
      redirect_to root_path, notice: "Greška prilikom prijave!"
    end
  end

  def finish_sign_up
    log_in_with_nias
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
      user = User.where(id: params[:id]).first
      if sign_in(:user, user)
        redirect_to root_path, notice: "Uspješno ste prijavljeni!"
      else
        redirect_to root_path, notice: "Greška prilikom prijave!"
      end
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
