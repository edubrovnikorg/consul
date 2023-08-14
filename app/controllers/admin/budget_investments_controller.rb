class Admin::BudgetInvestmentsController < Admin::BaseController
    include FeatureFlags
    include CommentableActions
    include FlagActions
    include RandomSeed
    include ImageAttributes
    include Translatable
    include InvestmentFilters

  feature_flag :budgets

  has_orders %w[oldest], only: [:show, :edit]
  has_filters %w[all], only: [:index, :toggle_selection]

  before_action :load_budget
  authorize_resource :budget, only: [:new, :create]
  load_and_authorize_resource :investment, through: :budget, class: "Budget::Investment",
                              only: [:new, :create]

  before_action :load_investment, only: [:show, :edit, :update, :toggle_selection, :delete_all]
  before_action :load_ballot, only: [:show, :index]
  before_action :parse_valuation_filters
  before_action :load_investments, only: [:index, :toggle_selection]
  before_action :load_categories, only: [:new, :create]

  def new
    @investment = @budget.investments.build
  end

  def create
    @investment = @budget.investments.build(investment_params)
    @investment.author = current_user

    if @investment.save
      Mailer.budget_investment_created(@investment).deliver_later
      redirect_to admin_budget_budget_investments_path(@budget),
                  notice: t("flash.actions.create.budget_investment")
    else
      render :new
    end
  end

  def import_budget_investments
    return redirect_to request.referer, notice: 'Niste dodali datoteku.' if params[:file].nil?
    return redirect_to request.referer, notice: 'Dozvoljene su samo CSV datoteke.' unless params[:file].content_type == 'text/csv'
    logger.debug "Import started..."
    ImportService.new.call(params[:file]) do |res|
      logger.debug "CSV import row: #{res}"
      budget_investment = {
        "author" => current_user,
        "heading_id"=> res["Subgroup"],
        "tag_list"=>"",
        "organization_name"=>"",
        "location"=>"",
        "terms_of_service"=>"1",
        "translations_attributes"=>
          {
            "0"=>
              {
                "locale"=>"hr",
                "_destroy"=>"false",
                "title"=> res["Name"],
                "description"=>"<p>" + res["Description"] + "</p>\r\n"
              }
          }
      }

      investment = @budget.investments.build(budget_investment);
      logger.debug "CSV import investment: #{investment}"

      if investment.save
        logger.info "CSV import row success"
      else
        logger.error "CSV import row error!"
      end
    end

    redirect_to admin_budget_budget_investments_path(@budget)
  end

  def index
    load_tags
    respond_to do |format|
      format.html
      format.js
      format.csv do
        send_data Budget::Investment::Exporter.new(@investments).to_csv,
                  filename: "budget_investments.csv"
      end
    end
  end

  def show
    load_comments
  end

  def edit
    authorize! :admin_update, @investment
    load_staff
    load_valuator_groups
    load_tags
  end

  def update
    authorize! :admin_update, @investment

    respond_to do |format|
      format.html do
        if @investment.update(budget_investment_params)
          redirect_to admin_budget_budget_investment_path(@budget,
                                                          @investment,
                                                          Budget::Investment.filter_params(params).to_h),
                      notice: t("flash.actions.update.budget_investment")
        else
          load_staff
          load_valuator_groups
          load_tags
          render :edit
        end
      end

      format.json do
        @investment.update!(budget_investment_params)
      end
    end
  end

  def toggle_selection
    authorize! :toggle_selection, @investment
    @investment.toggle :selected
    @investment.save!
    load_investments
  end

  def delete_all
    if @investment.delete
      redirect_to admin_budget_budget_investments_path(@budget), notice: t("admin.budget_investments.destroy.success")
    else
      redirect_to admin_budget_budget_investments_path(@budget), notice: t("admin.budget_investments.destroy.failure")
    end
  end

  private

    def load_comments
      @commentable = @investment
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order, valuations: true)
      set_comment_flags(@comment_tree.comments)
    end

    def resource_model
      Budget::Investment
    end

    def resource_name
      resource_model.parameterize(separator: "_")
    end

    def load_investments
      @investments = Budget::Investment.scoped_filter(params, @current_filter).order_filter(params)
      @investments = Kaminari.paginate_array(@investments) if @investments.is_a?(Array)
      @investments = @investments.page(params[:page]) unless request.format.csv?
    end

    def budget_investment_params
      attributes = [:external_url, :heading_id, :administrator_id, :tag_list,
                    :valuation_tag_list, :incompatible, :visible_to_valuators, :selected,
                    :milestone_tag_list, valuator_ids: [], valuator_group_ids: []]
      params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
    end


      def investment_params
        attributes = [:heading_id, :tag_list, :organization_name, :location,
                      :terms_of_service, :skip_map, :related_sdg_list,
                      image_attributes: image_attributes,
                      documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy],
                      map_location_attributes: [:latitude, :longitude, :zoom]]
        params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
      end

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_investment
      @investment = @budget.investments.find(params[:id] || params[:budget_investment_id])
    end

    def load_staff
      @admins = @budget.administrators.includes(:user)
      @valuators = @budget.valuators.includes(:user).order(description: :asc).order("users.email ASC")
    end

    def load_valuator_groups
      @valuator_groups = ValuatorGroup.all.order(name: :asc)
    end

    def load_tags
      @tags = Budget::Investment.tags_on(:valuation_tags).order(:name).distinct
    end

    def load_ballot
      query = Budget::Ballot.where(user: current_user, budget: @budget)
      @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize
    end

    def parse_valuation_filters
      if params[:valuator_or_group_id]
        model, id = params[:valuator_or_group_id].split("_")

        if model == "group"
          params[:valuator_group_id] = id
        else
          params[:valuator_id] = id
        end
      end
    end

    def budget_investment_import_params
      return {} unless params[:file].present?

      params.require(:file)
    end
end
