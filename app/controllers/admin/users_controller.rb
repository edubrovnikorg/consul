class Admin::UsersController < Admin::BaseController

  has_filters %w[active erased not_approved], only: :index

  before_action :load_user, only: [:approve]

  load_and_authorize_resource

  def index
    @users = @users.send(@current_filter)
    @users = @users.by_username_email_or_document_number(params[:search]) if params[:search]
    @users = @users.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def approve
    @user[:approved] = true;
    @user[:confirmed_at] = Time.now.utc;
    if @user.save
      redirect_to admin_users_path(filter: @current_filter, page: "1")
    else
      render :index
    end
  end

  private
    def load_user
      @budget = User.find_by_id! params[:id]
    end
end
