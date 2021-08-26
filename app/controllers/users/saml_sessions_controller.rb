class Users::SamlSessionsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  prepend_before_action :authenticate_user!, only: [:ssout, :destroy]
  prepend_before_action :allow_params_authentication!, only: :auth

  def show
    begin
      @user = get_nias_user(:session)
    rescue StandardError => e
        logger.debug "[ERROR] => #{e}"
        flash[:error] = "Pogreška prilikom prijave! Morate biti iz Dubrovnika ili okolnih gradova kako biste se prijavili."
        redirect_to root_path 
        return
    end
    render :index
  end

  def sson
    redirect_to url_nias(:login), turbolinks:false
  end

  def auth
    logger.debug "PARAMS >> #{params}"
    if User.is_local? params[:mjesto]
      begin
        user = get_nias_user(:login)
        head :no_content 
      rescue StandardError => e
        head 422
      end
    else
      begin
        raise StandardError, "User validation error."
      rescue StandardError => e
        head 403
      end
    end
  end
  
  def ssout
    redirect_to url_nias(:logout), turbolinks:false
  end

  def after_initiate_logout
    prepare_user_for_logout

    head :no_content 
  end

  def finish_sign_up
    log_in_with_nias
  end

  def finish_sign_out
    log_out_with_nias
  end

  def flush_user
    flush_user_data
  end

  private

    def url_nias(action)
      url = "http://#{request.host_with_port}:8443/NiasIntegrationTest"

      case action
      when :login
        url << "/loginNiasRequest";
      when :logout
        subject_id = CGI.escape(current_user.subject_id)
        subject_id_format = CGI.escape(current_user.subject_id_format)
        session_index = CGI.escape(current_user.session_index)
        url << "/logoutNiasRequest?subjectId=#{subject_id}&subjectIdFormat=#{subject_id_format}&sessionIndex=#{session_index}" 
      end

      url
    end

    def get_nias_user(action, param = nil)
        user = nil 
        case action
        when :login
          user = User.first_or_initialize_for_nias(nias_params)
          raise StandardError, "Pogreška prilikom prijave! Nepostojeći korisnik" unless user
        when :session
          user = User.where(session_index: params[:sessionIndex]).where(subject_id: params[:subjectId]).first
          raise StandardError, "Pogreška prilikom prijave! Nepostojeći korisnik." unless user
        when :logout
          user = User.where(logout_request_id: param).first
          raise StandardError, "Pogreška pri odjavi! Korisnik nije odjavljen." unless user
        end
      user
    end

    def prepare_user_for_logout
      begin
        raise StandardError, "Pogreška pri odjavi! Korisnik nije odjavljen." unless params[:requestId]
        user = get_nias_user(:session)
      rescue StandardError => e
        flash[:error] = e.message
        redirect_to root_path 
        return
      end
      user.logout_request_id = params[:requestId]
      user.save!
    end

    def log_in_with_nias
      logger.debug "CHECK IF USER EXISTS >> #{@user}"
      user = User.where(id: params[:id]).first
      # raise("No user found for log in.") unless user
      if sign_in(:user, user)
        redirect_to root_path, notice: "Uspješno ste prijavljeni!"
      else
        redirect_to root_path, error: "Greška prilikom prijave!"
      end
    end

    def flush_user_data
      begin
        user = get_nias_user(:session)
      rescue StandardError => e
        logger.debug "Flushing users failed!"
        return 500;
      end
      sign_out user
      if !user.invalidate_all_sessions!
        logger.debug "Flushing users failed!"
        head :bad_request
      else
        head :ok
      end
    end

    def log_out_with_nias
      data = Base64.decode64(params[:response])
      data = JSON.parse(data, object_class: OpenStruct)

      begin
        user = get_nias_user(:logout, data[:requestId])
      rescue StandardError => e
        flash[:error] = e.message
        redirect_to root_path 
        return
      end
      
      if logout_status_ok data
        sign_out user
        user.invalidate_all_sessions!
        redirect_to root_path, notice: "Uspješno ste odjavljeni!"
      else
        redirect_to root_path, error: "Odjava je zaustavljena."
      end
    end

    def logout_status_ok(data)
      data[:statusCode].slice! "urn:oasis:names:tc:SAML:2.0:status:"
      if data[:statusCode] == "PartialLogout" || data[:statusCode] == "Success"
        return true
      else
        return false;
      end
    end

    def nias_params
      params.require([:ime, :prezime, :oib, :tid, :sessionIndex, :subjectId, :subjectIdFormat, :drzava, :opcina, :mjesto, :adresa])
      username = ('a'..'z').to_a.shuffle[0,8].join
      password = Devise.friendly_token[0, 20]
      params.merge(:locale => "hr", :username => username, :email => username+"@example.com", 
        :password => password, :password_confirmation => password, :terms_of_service => 1)
    end
end
