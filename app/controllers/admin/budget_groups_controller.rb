class Admin::BudgetGroupsController < Admin::BaseController
  include Translatable
  include FeatureFlags
  feature_flag :budgets

  before_action :load_budget
  before_action :load_group, except: [:index, :new, :create, :add_districts]

  def index
    @groups = @budget.groups.order(:id)
  end

  def new
    @group = @budget.groups.new
  end

  def edit
  end

  def create
    @group = @budget.groups.new(budget_group_params)
    if @group.save
      redirect_to groups_index, notice: t("admin.budget_groups.create.notice")
    else
      render :new
    end
  end

  def add_districts
    @districts = ::District.all
    @districts.uniq.pluck(:category).each do |category|
      hash = {"translations_attributes"=>{"0"=>{"locale"=>"hr", "_destroy"=>"false", "name"=> category === 0 ? "Gradski kotar" : "Mjesni odbor" }}}
      group = @budget.groups.new(hash)
      group.save
    end
    @districts.each do |district|
      group = @budget.groups.find_by_slug(district.category == 0 ? "gradski-kotar" : "mjesni-odbor")
      hash = {
        "price"=>"10",
        "population"=>"",
        "budget_id" => @budget.id,
        "district_id" => district.id,
        "allow_custom_content"=>"0",
        "latitude"=>"",
        "longitude"=>"",
        "translations_attributes"=>
          {
            "0"=>
            {
              "locale"=>"hr",
              "_destroy"=>"false",
              "name"=> district.name
            }
          }
        }
      group.headings.new(hash)
      group.save
    end
    redirect_to admin_budget_groups_path(@budget)
  end

  def update
    if @group.update(budget_group_params)
      redirect_to groups_index, notice: t("admin.budget_groups.update.notice")
    else
      render :edit
    end
  end

  def destroy
    if @group.headings.any?
      redirect_to groups_index, alert: t("admin.budget_groups.destroy.unable_notice")
    else
      @group.destroy!
      redirect_to groups_index, notice: t("admin.budget_groups.destroy.success_notice")
    end
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_group
      @group = @budget.groups.find_by_slug_or_id! params[:id]
    end

    def groups_index
      admin_budget_groups_path(@budget)
    end

    def budget_group_params
      valid_attributes = [:max_votable_headings]
      params.require(:budget_group).permit(*valid_attributes, translation_params(Budget::Group))
    end
end
