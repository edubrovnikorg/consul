module StreetsHelper
  def street_filter_helper(current_user, poll)
    result = true

    unless current_user.address.present? || poll.streets.count > 0
      return result
    end

    poll.streets.each do |street|
      street_name = street.name.downcase
      user_address = current_user.address.downcase
      user_address = user_address.gsub!(/[[:space:]]\d+[a-z]*/, "")
      if street_name.include?(user_address) || user_address.include?(street_name)
        result = true
        break
      else
        result = false
      end
    end

    return result
  end

end
