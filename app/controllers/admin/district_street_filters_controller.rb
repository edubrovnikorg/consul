class Admin::DistrictStreetFiltersController < ApplicationController
  before_action :set_district_street
  before_action :set_district_street_filter, only: [:show, :edit, :update, :destroy]

  # GET /admin/district_street_filters
  def index
    @district_street_filters = DistrictStreetFilter.find_by_id(@district_street.id)
  end

  # GET /admin/district_street_filters/1
  def show
  end

  # GET /admin/district_street_filters/new
  def new
    @district_street_filter = @district_street.district_street_builder.build
  end

  # GET /admin/district_street_filters/1/edit
  def edit
  end

  # POST /admin/district_street_filters
  def create
    @district_street_filter = @district_street.district_street_builder.build(district_street_filter_params)

    if @district_street_filter.save
      redirect_to @district_street_filter, notice: 'District street filter was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /admin/district_street_filters/1
  def update
    if @district_street_filter.update(district_street_filter_params)
      redirect_to @district_street_filter, notice: 'District street filter was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /admin/district_street_filters/1
  def destroy
    @district_street_filter.destroy
    redirect_to district_street_filters_url, notice: 'District street filter was successfully destroyed.'
  end

  private

    def set_district_street
      @district_street = DistrictStreet.find(params[:district_street_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_district_street_filter
      @district_street_filter = DistrictStreetFilter.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def district_street_filter_params
      params.require(:district_street_filter).permit(:district_streets_id, :from, :to)
    end


end
