module InvestmentsVoteHelper
  def votes_to_percent(votes, total_votes)
    (votes / total_votes) * 100
  end
end
