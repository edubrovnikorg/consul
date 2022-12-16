class Poll
  class Street < ApplicationRecord
    self.table_name = "streets"
    has_and_belongs_to_many :poll
    before_destroy { poll.clear }

    def self.search(terms)
      Street.where("name ILIKE ? OR county ILIKE ?", "%#{terms}%", "%#{terms}%")
    end
  end
end
