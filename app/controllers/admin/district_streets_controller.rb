class Admin::DistrictStreetsController < Admin::BaseController
  load_and_authorize_resource

  before_action :set_district
  before_action :set_category
  before_action :set_district_streets, only: [:edit, :update, :destroy]

  def new
    @district_street = @district.district_streets.build
  end

  def index

  end

  def create
    @district_street = @district.district_streets.build(district_street_params);
    if @district_street.save
      redirect_to admin_district_district_streets_path, notice: t("admin.district.notice.created", type: @category, name: @district.name)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @district_street.update(district_street_params)
      redirect_to admin_district_district_streets_path, notice: t("admin.district_streets.notice.updated", type: @category, name: @district.name)
    else
      render :edit
    end
  end

  # DELETE /admin/district_streets/1
  def destroy
    @district_street.destroy
    redirect_to admin_district_district_streets_path, notice: 'Filter je uspješno uklonjen.'
  end

  private

  def set_district
    @district = District.find(params[:district_id])
  end

  def set_district_streets
    @district_street = DistrictStreet.includes(:district_street_filters).find(params[:id])
  end

  def set_category
    @category = @district.category == 0 ? "Gradski kotar" : "Mjesni odbor"
  end

  def district_street_params
    params.require(:district_street).permit(:name, district_street_filters_attributes: [:id, :from, :to, :_destroy])
  end
end
