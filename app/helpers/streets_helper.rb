module StreetsHelper
  def street_filter_helper(current_user, poll)
    result = true

    poll.streets.each do |street|
      street_name = street.name.downcase
      user_address = current_user.address.downcase
      user_address = user_address.gsub!(/[[:space:]]\d+[a-z]*/, "")
      unless street_name == user_address
        result = false
        break
      end
    end

    return result
  end

end
