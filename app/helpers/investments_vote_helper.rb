module InvestmentsVoteHelper
  def votes_to_percent(votes, total_votes)
    return 0 if votes.zero? || total_votes.zero?
    return '%.2f' % ((votes.to_f / total_votes.to_f) * 100);
  end
end



