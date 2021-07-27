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
    redirect_to url_nias(:logout), turbolinks:false
  end

  def finish_sign_up
    log_in_with_nias
  end

  def finish_sign_out
    log_out_with_nias
  end

  private

    def url_nias(action)
      url = "http://#{request.host_with_port}:8080/NiasIntegrationTest"

      case action
      when :login
        url << "/loginNiasRequest";
      when :logout
        url << "/logoutNiasRequest?subjectId=#{current_user.subject_id}&subjectIdFormat=#{current_user.subject_id_format}&sessionIndex=#{current_user.session_index}" 
      end

      url
    end

    def get_nias_user
      User.where(session_index: params[:sessionIndex]).where(subject_id: params[:subjectId]).first
    end

    def log_in_with_nias
      user = User.where(id: params[:id]).first
      if sign_in(:user, user)
        redirect_to root_path, notice: "Uspješno ste prijavljeni!"
      else
        redirect_to root_path, notice: "Greška prilikom prijave!"
      end
    end

    def log_out_with_nias
      logger.debug "CURRENT USER >> #{current_user}"
      logger.debug "STATUS >> #{params}"

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
