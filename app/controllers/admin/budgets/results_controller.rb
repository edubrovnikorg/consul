class Admin::Budgets::ResultsController < Admin::BaseController
    before_action :load_budget
    before_action :load_heading

    authorize_resource :budget

    helper InvestmentsVoteHelper

    def show
      authorize! :read_results, @budget
      @investments = Budget::Result.new(@budget, @heading).investments
      @headings = @budget.headings.sort_by { |heading| heading.id }
      @total_votes = 0
      @investments.each do |investment|
        @total_votes += investment.votes_for.size
      end
      @total_votes_in_budget = 0
      @budget.investments.each do |investment|
        @total_votes_in_budget += investment.votes_for.size
      end
      @sorted_investments = [];
      winner = nil
      @investments.each do |investment|
        if investment.winner?
          winner = investment
        else
          @sorted_investments.push(investment)
        end
      end
      logger.debug "BEFORE >>>>>"
      logger.debug @sorted_investments.select { |i| i.votes_for.size }
      @sorted_investments = @sorted_investments.sort { |i| i.votes_for.size }.reverse
      logger.debug "AFTER >>>>>"
      logger.debug @sorted_investments.select { |i| i.votes_for.size }
      unless winner.nil?
        @sorted_investments.unshift(winner)
      end
    end

    private

    def load_budget
      @budget = Budget.find_by_slug_or_id(params[:budget_id]) || Budget.first
    end

    def load_heading
      if @budget.present?
        headings = @budget.headings
        @heading = headings.find_by_slug_or_id(params[:heading_id]) || headings.first
      end
    end
end
