class Admin::DistrictsController < Admin::BaseController
  load_and_authorize_resource
  before_action :set_district, only: [:edit, :update, :destroy, :destroy_streets]
  before_action :set_category, except: [:new, :index, :import, :import_streets, :delete_all]


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
      redirect_to admin_districts_path, alert: t("admin.district.notice.delete_success", type: @category, name: @district.name)
    end
  end

  def import
    return redirect_to request.referer, notice: 'Niste dodali datoteku.' if params[:file].nil?
    return redirect_to request.referer, notice: 'Dozvoljene su samo CSV datoteke.' unless params[:file].content_type == 'text/csv'

    ImportService.new.call(params[:file]) do |res|
      district_hash = Hash.new
      district_hash[:name] = res["name"]
      district_hash[:category] = res["category"]
      District.find_or_create_by!(district_hash);
    end

    render :index
  end

  def import_streets
    return redirect_to request.referer, notice: 'Niste dodali datoteku.' if params[:file].nil?
    return redirect_to request.referer, notice: 'Dozvoljene su samo CSV datoteke.' unless params[:file].content_type == 'text/csv'

    ImportService.new.call(params[:file]) do |res|
      district_streets_hash = Hash.new
      district_streets_hash[:name] = res["name"]
      district_streets_hash[:district] = District.find(res["kotar/odbor"]);

      DistrictStreet.find_or_create_by!(district_streets_hash);
    end

    render :index
  end

  def delete_all
    District.all.each do |district|
      DistrictStreet.where(district_id: district.id).destroy_all
    end
    District.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!('districts')
    render :index
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
