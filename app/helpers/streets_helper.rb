module StreetsHelper
  def street_filter_helper(current_user, poll)
    result = true

    poll.streets.each do |street|
      street_name = street.name.downcase
      user_address = current_user.address.downcase
      user_address = user_address.gsub!(/[[:space:]]\d+[a-z]*/, "")
      unless street_name.include?(user_address) || user_address.include?(street_name)
        result = false
      else
        result = true
        break
      end
    end

    return result
  end

end
