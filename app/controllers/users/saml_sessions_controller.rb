class Users::SamlSessionsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  prepend_before_action :authenticate_user!, only: [:ssout, :destroy]
  prepend_before_action :allow_params_authentication!, only: :auth

  def show
    unless user_signed_in? && !user_in_session
      @user = get_nias_user(:session)
      if @user.nias_session.user_type == :non_local
        @params = failed_sign_up_params
        @params["subjectIdFormat"] = non_local[:subjectIdFormat]
      end

      render :index
    else
      redirect_to root_path
    end
  end

  def sson
    redirect_to url_nias(:login), turbolinks: false
  end

  def auth
    user = get_nias_user(:login)
    head 422 unless user

    if User.is_local? params[:mjesto]
      user.create_nias_session(:session_index => params[:sessionIndex], :subject_id => params[:subjectId], :subject_id_format => params[:subjectIdFormat], :user_type => :local, :login_status => :authenticated);
      head :no_content
    else
      user.create_nias_session(:session_index => params[:sessionIndex], :subject_id => params[:subjectId], :subject_id_format => params[:subjectIdFormat], :user_type => :non_local, :login_status => :login_denied);
      head 403
    end
  end

  def finish_sign_up
    log_in_with_nias
  end

  def ssout
    redirect_to url_nias(:logout), turbolinks: false
  end

  def after_initiate_logout
    if params[:requestId]
      user = get_nias_user(:session)
      user.logout_request_id = params[:requestId]
      user.save!
      user.nias_session.update(:logout_status => :requested)
    else
      redirect_to root_path, error: "Greška! Molimo ponovite radnju."
    end
    head :no_content
  end

  def finish_sign_out
    log_out_with_nias
  end

  def failed_sign_up
    redirect_to url_nias(:logout_nias), turbolinks: false
  end

  def flush_user
    flush_user_data
  end

  private

  #### LOGIN

  def log_in_with_nias
    unless user_signed_in? && !user_in_session
      user = User.where(id: finish_sign_up_params).first
      if sign_in(:user, user)
        user.nias_session.update(:login_status => :login_finished)
        redirect_to root_path, notice: "Uspješno ste prijavljeni!"
      else
        redirect_to root_path, error: "Greška prilikom prijave!"
      end
    else
      redirect_to root_path, info: "Već ste prijavljeni"
    end
  end

  #### LOGOUT

  def flush_user_data
    begin
      user = get_nias_user(:session)
    rescue StandardError => e
      logger.error "Flushing users failed!"
      return 500
    end
    sign_out user
    if !user.invalidate_all_sessions!
      logger.error "Flushing users failed!"
      head :bad_request
    else
      user.nias_session.destroy
      head :ok
    end
  end

  def log_out_with_nias
    data = Base64.decode64(params[:response])
    data = JSON.parse(data, object_class: OpenStruct)
    user = get_nias_user(:logout, data[:requestId])
    head 422 unless user
    if logout_status_ok data
      # Get user and invalidate all sessions
      sign_out user
      user.invalidate_all_sessions!
      user.nias_session.destroy
      redirect_to root_path, notice: "Uspješno ste odjavljeni!"
    else
      # Non-local users must be redirected to index
      user.nias_session.update(:logout_status => :logout_denied)
      if user.nias_session.user_type == "non_local"
        params = {:sessionIndex => user.nias_session.session_index, :subjectId => user.nias_session.subject_id}
        redirect_to nias_index_path(params), error: "Odjava odbijena. Radi ugodnijeg korisničkog iskustva vas molimo da se odjavite s usluge.", turbolinks: false
      else
        redirect_to root_path, error: "Odjava je zaustavljena.", turbolinks: false
      end
    end
  end

  #### UTIL

  def user_in_session(user)
    return false if user.nias_session.count = 0
  end

  def logout_status_ok(data)
    data[:statusCode].slice! "urn:oasis:names:tc:SAML:2.0:status:"
    if data[:statusCode] == "PartialLogout" || data[:statusCode] == "Success"
      return true
    else
      return false
    end
  end

  def url_nias(action)
    url = "http://#{request.host_with_port}:8443/NiasIntegrationTest"

    case action
    when :login
      url << "/loginNiasRequest"
    when :logout
      subject_id = CGI.escape(current_user.subject_id)
      subject_id_format = CGI.escape(current_user.subject_id_format)
      session_index = CGI.escape(current_user.session_index)
      url << "/logoutNiasRequest?subjectId=#{subject_id}&subjectIdFormat=#{subject_id_format}&sessionIndex=#{session_index}"
    when :logout_nias
      subject_id = CGI.escape(params[:subjectId])
      subject_id_format = CGI.escape(params[:subjectIdFormat])
      session_index = CGI.escape(params[:sessionIndex])
      url << "/logoutNiasRequest?subjectId=#{subject_id}&subjectIdFormat=#{subject_id_format}&sessionIndex=#{session_index}"
    end
    url
  end

  def get_nias_user(action, param = nil)
    user = nil
    case action
    when :login
      user = User.first_or_initialize_for_nias(nias_params)
    when :session
      user = User.where(session_index: params[:sessionIndex]).where(subject_id: params[:subjectId]).first
    when :logout
      user = User.where(logout_request_id: param).first
    end
    user
  end

  #### PARAMETERS

  def nias_params
    params.require([:ime, :prezime, :oib, :tid, :sessionIndex, :subjectId, :subjectIdFormat, :drzava, :opcina, :mjesto, :adresa])
    username = ("a".."z").to_a.shuffle[0, 8].join
    password = Devise.friendly_token[0, 20]
    params.merge(:locale => "hr", :username => username, :email => username + "@example.com",
                 :password => password, :password_confirmation => password, :terms_of_service => 1)
  end

  def finish_sign_up_params
    params.require([:id])
  end

  def failed_sign_up_params
    params.require([:sessionIndex, :subjectId])
    params.permit([:sessionIndex, :subjectId, :subjectIdFormat])
  end
end
