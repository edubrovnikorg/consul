class Admin::DistrictsController < Admin::BaseController
  load_and_authorize_resource
  before_action :set_district, only: [:edit, :update, :destroy]
  before_action :set_category, except: [:new, :index]


  def new

  end

  def index
  end

  def create
    @district = District.new(district_params)
    if @district.save
      redirect_to admin_districts_path, notice: t("admin.district.notice.created", type: @category)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @district.update(district_params)
      redirect_to admin_districts_path, notice: t("admin.district.notice.updated", type: @category)
    else
      render :edit
    end
  end

  def destroy
    if @district.district_streets.any?
      redirect_to admin_districts_path, alert: t("admin.district_streets.notice.exists", type: @category, name: @district.name)
    else
      @district.destroy!
      redirect_to admin_districts_path, t("admin.district.notice.delete_success", type: @category, name: @district.name)
    end
  end

  private

  def set_category
    @category = @district.category == 0 ? "Gradski kotar" : "Mjesni odbor"
  end

  def set_district
    @district = District.find(params[:id] || params[:format])
  end

  def district_params
    params.require(:district).permit(:name, :category)
  end
end
