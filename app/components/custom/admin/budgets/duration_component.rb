require_dependency Rails.root.join("app", "components", "admin", "budgets", "duration_component").to_s

class Admin::Budgets::DurationComponent
  private

    def formatted_date(time)
      time.strftime("%d.%m.%Y.")
    end
end
