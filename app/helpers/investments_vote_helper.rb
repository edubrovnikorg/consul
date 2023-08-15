module InvestmentsVoteHelper
  def votes_to_percent(votes, total_votes)
    return 0 if votes.zero? && total_votes.zero?
    return ((votes.to_f / total_votes.to_f) * 100).round(0);
  end
end
