class Admin::BudgetImagesController < Admin::BaseController
  include ImageAttributes

  load_and_authorize_resource :budget_image, except: [:create]
  before_action :set_admin_budgets_image, only: [:edit, :update, :destroy]

  # GET /admin/budgets/images
  def index
  end

  # GET /admin/budgets/images/new
  def new
    @budget_image = BudgetImage.new
  end

  # GET /admin/budgets/images/1
  def show
  end

  # GET /admin/budgets/images/1/edit
  def edit
  end

  # POST /admin/budgets/images
  def create
    @budget_image = BudgetImage.new(admin_budgets_image_params)

    if @budget_image.save
      redirect_to admin_budget_images_path, notice: 'Uspješno ste dodali sliku.'
    else
      render :new
    end
  end

  # PATCH/PUT /admin/budgets/images/1
  def update
    if @budget_image.update(admin_budgets_image_params)
      redirect_to admin_budget_images_path, notice: 'Uspješno ste uredili sliku.'
    else
      render :edit
    end
  end

  # DELETE /admin/budgets/images/1
  def destroy
    @budget_image.destroy
    redirect_to admin_budget_images_path, notice: 'Slika je uklonjena.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_budgets_image
      @budget_image = BudgetImage.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def admin_budgets_image_params
      params.require(:budget_image).permit(image_attributes: image_attributes)
    end
end
