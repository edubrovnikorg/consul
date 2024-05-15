class Admin::DistrictZonesController < Admin::BaseController
  load_and_authorize_resource

  before_action :set_district
  before_action :set_category
  before_action :set_district_zone, only: [:edit, :update, :destroy]

  # GET /admin/district_zones
  def index
    @admin_district_zones = DistrictZone.where(district_id: @district.id)
  end

  # GET /admin/district_zones/1
  def show
  end

  # GET /admin/district_zones/new
  def new
    @admin_district_zone = DistrictZone.new
  end

  # GET /admin/district_zones/1/edit
  def edit
  end

  # POST /admin/district_zones
  def create
    @admin_district_zone = @district.district_zones.build(district_zone_params);

    if @admin_district_zone.save
      redirect_to admin_district_district_zones_path, notice: t("admin.district.district_zones.notice.created", type: @category, name: @district.name)
    else
      render :new
    end
  end

  # PATCH/PUT /admin/district_zones/1
  def update
    if @admin_district_zone.update(district_zone_params)
      redirect_to admin_district_district_zones_path, notice: t("admin.district.district_zones.notice.updated", type: @category, name: @district.name)
    else
      render :edit
    end
  end

  # DELETE /admin/district_zones/1
  def destroy
    @admin_district_zone.destroy
    redirect_to admin_district_district_zones_path, notice: t("admin.district.district_zones.notice.deleted", type: @category, name: @district.name)
  end

  def delete_zones
    @district.streets.delete_all
    render :index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_district_zone
      @admin_district_zone = DistrictZone.find(params[:id])
    end

    def set_district
      @district = District.find(params[:district_id])
    end

    def set_category
      @category = @district.category == 0 ? "Gradski kotar" : "Mjesni odbor"
    end

    # Only allow a trusted parameter "white list" through.
    def district_zone_params
      params.require(:district_zone).permit(:name)
    end
end
