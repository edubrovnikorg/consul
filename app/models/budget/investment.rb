class Budget
  class Investment < ApplicationRecord
    SORTING_OPTIONS = { id: "id", supports: "cached_votes_up" }.freeze

    include Rails.application.routes.url_helpers
    include Measurable
    include Sanitizable
    include Taggable
    include Searchable
    include Reclassification
    include Followable
    include Communitable
    include Imageable
    include Mappable
    include Documentable
    include SDG::Relatable

    acts_as_taggable_on :valuation_tags
    acts_as_votable
    acts_as_paranoid column: :hidden_at
    include ActsAsParanoidAliases
    include Relationable
    include Notifiable
    include Filterable
    include Flaggable
    include Milestoneable
    include Randomizable

    translates :title, touch: true
    translates :description, touch: true
    include Globalizable

    audited on: [:update, :destroy]
    has_associated_audits
    translation_class.class_eval do
      audited associated_with: :globalized_model,
              only: Budget::Investment.translated_attribute_names
    end

    belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :budget_investments
    belongs_to :heading, :autosave => true
    belongs_to :group
    belongs_to :budget
    belongs_to :administrator

    has_many :valuator_assignments, dependent: :destroy
    has_many :valuators, through: :valuator_assignments

    has_many :valuator_group_assignments, dependent: :destroy
    has_many :valuator_groups, through: :valuator_group_assignments

    has_many :comments, -> { where(valuation: false) }, as: :commentable, inverse_of: :commentable
    has_many :valuations, -> { where(valuation: true) },
      as:         :commentable,
      inverse_of: :commentable,
      class_name: "Comment"

    validates_translation :title, presence: true, length: { in: 4..Budget::Investment.title_max_length }
    validates_translation :description, presence: true, length: { maximum: Budget::Investment.description_max_length }

    validates :author, presence: true
    validates :heading_id, presence: true
    validates :unfeasibility_explanation, presence: { if: :unfeasibility_explanation_required? }
    validates :price, presence: { if: :price_required? }
    validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

    scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc, id: :desc) }
    scope :sort_by_ballots,          -> { reorder(ballot_lines_count: :desc, id: :desc) }
    scope :sort_by_price,            -> { reorder(price: :desc, confidence_score: :desc, id: :desc) }

    scope :sort_by_id, -> { order("id DESC") }
    scope :sort_by_supports, -> { order("cached_votes_up DESC") }

    scope :valuation_open,              -> { where(valuation_finished: false) }
    scope :without_admin,               -> { where(administrator_id: nil) }
    scope :without_valuator_group,      -> { where(valuator_group_assignments_count: 0) }
    scope :without_valuator,            -> { without_valuator_group.where(valuator_assignments_count: 0) }
    scope :under_valuation,             -> { valuation_open.valuating.where("administrator_id IS NOT ?", nil) }
    scope :managed,                     -> { valuation_open.where(valuator_assignments_count: 0).where("administrator_id IS NOT ?", nil) }
    scope :valuating,                   -> { valuation_open.where("valuator_assignments_count > 0 OR valuator_group_assignments_count > 0") }
    scope :visible_to_valuators,        -> { where(visible_to_valuators: true) }
    scope :valuation_finished,          -> { where(valuation_finished: true) }
    scope :valuation_finished_feasible, -> { where(valuation_finished: true, feasibility: "feasible") }
    scope :feasible,                    -> { where(feasibility: "feasible") }
    scope :unfeasible,                  -> { where(feasibility: "unfeasible") }
    scope :not_unfeasible,              -> { where.not(feasibility: "unfeasible") }
    scope :undecided,                   -> { where(feasibility: "undecided") }
    scope :with_supports,               -> { where("cached_votes_up > 0") }
    scope :selected,                    -> { feasible.where(selected: true) }
    scope :compatible,                  -> { where(incompatible: false) }
    scope :incompatible,                -> { where(incompatible: true) }
    scope :winners,                     -> { selected.compatible.where(winner: true) }
    scope :unselected,                  -> { not_unfeasible.where(selected: false) }
    scope :last_week,                   -> { where("created_at >= ?", 7.days.ago) }
    scope :sort_by_flags,               -> { order(flags_count: :desc, updated_at: :desc) }
    scope :sort_by_created_at,          -> { reorder(created_at: :desc) }

    scope :by_budget,         ->(budget)      { where(budget: budget) }
    scope :by_group,          ->(group_id)    { where(group_id: group_id) }
    scope :by_heading,        ->(heading_id)  { where(heading_id: heading_id) }
    scope :by_admin,          ->(admin_id)    { where(administrator_id: admin_id) }
    scope :by_tag,            ->(tag_name)    { tagged_with(tag_name).distinct }

    scope :for_render, -> { includes(:heading) }

    def self.by_valuator(valuator_id)
      where("budget_valuator_assignments.valuator_id = ?", valuator_id).joins(:valuator_assignments)
    end

    def self.by_valuator_group(valuator_group_id)
      joins(:valuator_group_assignments).
        where("budget_valuator_group_assignments.valuator_group_id = ?", valuator_group_id)
    end

    before_create :set_original_heading_id
    before_save :calculate_confidence_score
    after_save :recalculate_heading_winners
    before_validation :set_responsible_name
    before_validation :set_denormalized_ids

    def comments_count
      comments.count
    end

    def url
      budget_investment_path(budget, self)
    end

    def self.sort_by_title
      all.sort_by(&:title)
    end

    def self.filter_params(params)
      params.permit(%i[heading_id group_id administrator_id tag_name valuator_id])
    end

    def self.scoped_filter(params, current_filter)
      budget  = Budget.find_by_slug_or_id params[:budget_id]
      results = Investment.by_budget(budget)

      results = results.where("cached_votes_up + physical_votes >= ?",
                              params[:min_total_supports])                 if params[:min_total_supports].present?
      results = results.where("cached_votes_up + physical_votes <= ?",
                              params[:max_total_supports])                 if params[:max_total_supports].present?
      results = results.where(group_id: params[:group_id])                 if params[:group_id].present?
      results = results.by_tag(params[:tag_name])                          if params[:tag_name].present?
      results = results.by_tag(params[:milestone_tag_name])                if params[:milestone_tag_name].present?
      results = results.by_heading(params[:heading_id])                    if params[:heading_id].present?
      results = results.by_valuator(params[:valuator_id])                  if params[:valuator_id].present?
      results = results.by_valuator_group(params[:valuator_group_id])      if params[:valuator_group_id].present?
      results = results.by_admin(params[:administrator_id])                if params[:administrator_id].present?
      results = results.search_by_title_or_id(params[:title_or_id].strip)  if params[:title_or_id]
      results = advanced_filters(params, results)                          if params[:advanced_filters].present?

      results = results.send(current_filter) if current_filter.present?
      results.includes(:heading, :group, :budget, administrator: :user, valuators: :user)
    end

    def self.advanced_filters(params, results)
      results = results.without_admin      if params[:advanced_filters].include?("without_admin")
      results = results.without_valuator   if params[:advanced_filters].include?("without_valuator")
      results = results.under_valuation    if params[:advanced_filters].include?("under_valuation")
      results = results.valuation_finished if params[:advanced_filters].include?("valuation_finished")
      results = results.winners            if params[:advanced_filters].include?("winners")

      ids = []
      ids += results.valuation_finished_feasible.pluck(:id) if params[:advanced_filters].include?("feasible")
      ids += results.where(selected: true).pluck(:id)       if params[:advanced_filters].include?("selected")
      ids += results.undecided.pluck(:id)                   if params[:advanced_filters].include?("undecided")
      ids += results.unfeasible.pluck(:id)                  if params[:advanced_filters].include?("unfeasible")
      results = results.where(id: ids) if ids.any?
      results
    end

    def self.order_filter(params)
      sorting_key = params[:sort_by]&.downcase&.to_sym
      allowed_sort_option = SORTING_OPTIONS[sorting_key]
      direction = params[:direction] == "desc" ? "desc" : "asc"

      if allowed_sort_option.present?
        order("#{allowed_sort_option} #{direction}")
      elsif sorting_key == :title
        direction == "asc" ? sort_by_title : sort_by_title.reverse
      else
        order(cached_votes_up: :desc).order(id: :desc)
      end
    end

    def self.limit_results(budget, params, results)
      max_per_heading = params[:max_per_heading].to_i
      return results if max_per_heading <= 0

      ids = []
      budget.headings.pluck(:id).each do |hid|
        ids += Investment.where(heading_id: hid).order(confidence_score: :desc).limit(max_per_heading).pluck(:id)
      end

      results.where(id: ids)
    end

    def self.search_by_title_or_id(title_or_id)
      with_joins = with_translations(Globalize.fallbacks(I18n.locale))

      with_joins.where(id: title_or_id).
        or(with_joins.where("budget_investment_translations.title ILIKE ?", "%#{title_or_id}%"))
    end

    def searchable_values
      { author.username    => "B",
        heading.name       => "B",
        tag_list.join(" ") => "B"
      }.merge(searchable_globalized_values)
    end

    def self.search(terms)
      pg_search(terms)
    end

    def self.by_heading(heading)
      where(heading_id: heading == "all" ? nil : heading.presence)
    end

    def undecided?
      feasibility == "undecided"
    end

    def feasible?
      feasibility == "feasible"
    end

    def unfeasible?
      feasibility == "unfeasible"
    end

    def unfeasibility_explanation_required?
      unfeasible? && valuation_finished?
    end

    def price_required?
      feasible? && valuation_finished?
    end

    def unfeasible_email_pending?
      unfeasible_email_sent_at.blank? && unfeasible? && valuation_finished?
    end

    def total_votes
      cached_votes_up + physical_votes
    end

    def code
      "#{created_at.strftime("%Y")}-#{id}" + (administrator.present? ? "-A#{administrator.id}" : "")
    end

    def send_unfeasible_email
      Mailer.budget_investment_unfeasible(self).deliver_later
      update!(unfeasible_email_sent_at: Time.current)
    end

    def reason_for_not_being_selectable_by(user, investment = nil, district_id = nil)
      return permission_problem(user) if permission_problem?(user)
      return :different_heading_assigned if valid_heading?(user)

      if investment && district_id
        return district_problem(user, investment, district_id) if district_problem?(user, investment, district_id)
      end

      return :no_selecting_allowed unless budget.selecting?
    end

    def district_problem?(user, investment, district_id)
      district_problem(user,investment, district_id).present?
    end

    def district_problem(user, investment, district_id)
      return :no_district if user.address == 'f'

      selected_district = nil;
      city_district_count = District.where(category: 0).count
      city_name = mutate_city(user.city)
      result = nil

      if user.city
        if user.city.downcase != 'dubrovnik'
          user_district = District.where('name LIKE ?', "#{city_name.split.first.capitalize}%").first
          return :wrong_district if user_district.nil? || (user_district.id != district_id)
        else
          return :wrong_district if district_id > 8
        end
      end

      streets = DistrictStreet.where(district_id: district_id)


      streets.each do |street|
        puts "street #{street.name}"
        puts "last_result #{result}"
        street_name = street.name.downcase
        user_address = user.address.downcase
        user_number = user_address.delete("^0-9")

        if user_number == ""
          result = :no_district
          break
        elsif user_number
          user_address = user_address.gsub!(/[[:space:]]\d+[a-z]*/, "")
        end
        unless user_belongs_to_district(user_address, street_name)
          result = :wrong_district
          next
        end

        result = nil

        if street.district_street_filters.size > 0
          street.district_street_filters.each do |street_filter|
            # byebug if street.name == "Dr. Ante Šercera"

            filter = (street_filter.from..street_filter.to).step(2).to_a
            result = nil
            break if filter.include?(user_number.to_i)
            result = :wrong_district
          end
          break
        end
        break
      end
      result
    end

    def user_belongs_to_district(user_address, street_name)
      return false unless street_name.include?(user_address) || user_address.include?(street_name)
      similarity = (String::Similarity.cosine user_address.downcase, street_name.downcase) * 100
      if similarity > 80
        return true
      else
        return false
      end
    end

    def mutate_city(city)
      dubrovnik = ["sustjepan"]
      komolac = ["čajkovica", "čajkovići", "knežica", "prijevor", "rožat", "šumet"]
      mokosica = ["donje obuljeno", "gornje obuljeno", "nova mokošica", "petrovo selo", "pobrežje"]
      zaton = ["lozica", "zaton veliki"]

      if dubrovnik.include?(city.downcase)
        return "Dubrovnik"
      end
      if komolac.include?(city.downcase)
        return "Komolac"
      end
      if mokosica.include?(city.downcase)
        return "Mokošica"
      end
      if zaton.include?(city.downcase)
        return "Zaton"
      end
      city
    end

    def reason_for_not_being_ballotable_by(user, ballot)
      return permission_problem(user)    if permission_problem?(user)
      return :not_selected               unless selected?
      return :no_ballots_allowed         unless budget.balloting?
      return :different_heading_assigned unless ballot.valid_heading?(heading)
      return :casted_offline             if ballot.casted_offline?

      ballot.reason_for_not_being_ballotable(self)
    end

    def permission_problem(user)
      return :not_logged_in unless user
      return :organization  if user.organization?
      return :not_verified  unless user.can?(:vote, Budget::Investment)

      nil
    end

    def permission_problem?(user)
      permission_problem(user).present?
    end

    def selectable_by?(user)
      reason_for_not_being_selectable_by(user).blank?
    end

    def valid_heading?(user)
      voted_in?(heading, user)
      # || can_vote_in_another_heading?(user)
    end

    def can_vote_in_another_heading?(user)
      user.headings_voted_within_group(group).count < group.max_votable_headings
    end

    def voted_in?(heading, user)

      user.headings_voted_within_group(group).where(id: heading.id).exists?
    end

    def register_selection(user)
      vote_by(voter: user, vote: "yes") if selectable_by?(user)
    end

    def calculate_confidence_score
      self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_votes)
    end

    def recalculate_heading_winners
      Budget::Result.new(budget, heading).calculate_winners if saved_change_to_incompatible?
    end

    def set_responsible_name
      self.responsible_name = author&.document_number if author&.document_number.present?
    end

    def should_show_aside?
      (budget.selecting? && !unfeasible?) ||
        (budget.balloting? && feasible?) ||
        (budget.valuating? && !unfeasible?)
    end

    def should_show_votes?
      budget.selecting?
    end

    def should_show_vote_count?
      budget.valuating?
    end

    def should_show_ballots?
      budget.balloting? && selected?
    end

    def should_show_price?
      selected? && price.present? && budget.published_prices?
    end

    def should_show_price_explanation?
      should_show_price? && price_explanation.present?
    end

    def should_show_unfeasibility_explanation?
      unfeasible? && valuation_finished? && unfeasibility_explanation.present?
    end

    def formatted_price
      budget.formatted_amount(price)
    end

    def self.apply_filters_and_search(_budget, params, current_filter = nil)
      investments = all
      investments = investments.send(current_filter)             if current_filter.present?
      investments = investments.by_heading(params[:heading_id])  if params[:heading_id].present?
      investments = investments.search(params[:search])          if params[:search].present?
      investments = investments.filter_by(params[:advanced_search])
      investments
    end

    def assigned_valuators
      self.valuators.map(&:description_or_name).compact.join(", ").presence
    end

    def assigned_valuation_groups
      self.valuator_groups.map(&:name).compact.join(", ").presence
    end

    def self.with_milestone_status_id(status_id)
      includes(milestones: :translations).select do |investment|
        investment.milestone_status_id == status_id.to_i
      end
    end

    def milestone_status_id
      milestones.published.with_status.order_by_publication_date.last&.status_id
    end

    def admin_and_valuator_users_associated
      valuator_users = (valuator_groups.map(&:valuators) + valuators).flatten
      all_users = valuator_users << administrator
      all_users.compact.uniq
    end

    private

      def set_denormalized_ids
        self.group_id = heading&.group_id if will_save_change_to_heading_id?
        self.budget_id ||= heading&.group&.budget_id
      end

      def set_original_heading_id
        self.original_heading_id = heading_id
      end

      def searchable_translations_definitions
        { title       => "A",
          description => "D" }
      end
  end
end
