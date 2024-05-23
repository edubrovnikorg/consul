class Admin::BudgetsController < Admin::BaseController
  include Translatable
  include ReportAttributes
  include FeatureFlags
  feature_flag :budgets

  has_filters %w[all open finished], only: :index

  before_action :load_budget, except: [:index, :new, :create]
  before_action :load_staff, only: [:new, :create, :edit, :update, :show]
  load_and_authorize_resource

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
    render :edit
  end

  def new
  end

  def edit
  end

  def next_phase
    if @budget.phase == "reviewing"
      @budget.phase = :selecting
    elsif @budget.phase == "selecting"
      @budget.investments.sort_by_supports.each_with_index do |investment, key|
        if key == 0
          investment.winner = true
        end
        investment.feasibility = "feasible"
        investment.selected = true
        investment.save
      end
      @budget.phase = :finished;
    end
    @budget.save

    redirect_to admin_budgets_path, notice: t("admin.budgets.next_phase")
  end

  def publish
    @budget.phase = :reviewing
    @budget.save
    @budget.publish!
    redirect_to admin_budgets_path, notice: t("admin.budgets.publish.notice")
  end

  def calculate_winners
    return unless @budget.balloting_process?

    @budget.headings.each { |heading| Budget::Result.new(@budget, heading).delay.calculate_winners }
    redirect_to admin_budget_budget_investments_path(
                  budget_id: @budget.id,
                  advanced_filters: ["winners"]),
                notice: I18n.t("admin.budgets.winners.calculated")
  end

  def update
    if(budget_params[:phase] == 'accepting')
      @budget.published = false
      @budget.save
    end
    if @budget.update(budget_params)
      redirect_to admin_budgets_path, notice: t("admin.budgets.update.notice")
    else
      render :edit
    end
  end

  def create
    @budget = Budget.new(budget_params.merge(published: false))
    if @budget.save
      redirect_to edit_admin_budget_path(@budget), notice: t("admin.budgets.create.notice")
    else
      render :new
    end
  end

  def destroy
    if @budget.investments.any?
      redirect_to admin_budgets_path, alert: t("admin.budgets.destroy.unable_notice")
    elsif @budget.poll.present?
      redirect_to admin_budgets_path, alert: t("admin.budgets.destroy.unable_notice_polls")
    else
      @budget.destroy!
      redirect_to admin_budgets_path, notice: t("admin.budgets.destroy.success_notice")
    end
  end

  def delete_all
    if @budget.budget_administrators.exists?
      @budget.budget_administrators.delete_all
    end
    if @budget.budget_valuators.exists?
      @budget.budget_valuators.delete_all
    end
    if @budget.delete
      redirect_to admin_budgets_path, notice: t("admin.budgets.delete_all.success")
    else
      redirect_to admin_budgets_path, notice: t("admin.budgets.delete_all.failure")
    end
  end

  private

    def budget_params
      descriptions = Budget::Phase::PHASE_KINDS.map { |p| "description_#{p}" }.map(&:to_sym)
      valid_attributes = [:phase,
                          :currency_symbol,
                          :voting_style,
                          documents_attributes: [:id, :title, :attachment, :cached_attachment,
                          :user_id, :_destroy],
                          administrator_ids: [],
                          valuator_ids: []
      ] + descriptions
      params.require(:budget).permit(*valid_attributes, *report_attributes, translation_params(Budget))
    end

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id] || params[:budget_id]
    end

    def load_staff
      @admins = Administrator.includes(:user)
      @valuators = Valuator.includes(:user).order(description: :asc).order("users.email ASC")
    end
end
