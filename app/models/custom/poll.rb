require_dependency Rails.root.join("app", "models", "poll").to_s

class Poll < ApplicationRecord
  has_and_belongs_to_many :streets, optional: true
  before_destroy { streets.clear }

  accepts_nested_attributes_for :streets


end

