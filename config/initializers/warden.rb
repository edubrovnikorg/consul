require 'warden'
require 'devise/strategies/authenticatable'

module Devise
    module Strategies
        class NiasStrategy < Authenticatable
            def valid?
            params[:session_index].present?
            params[:oib].present?
            end
        
            def authenticate!
            puts "REQUEST>> #{request}"
            puts "SESSION>> #{session}"
            puts "PARAMS>> #{params}"


            user = User.first_or_initialize_for_nias(params)
        
            if user
                remember_me(user)
                user.after_database_authentication
                success!(user)
            else
                fail!('Invalid request')
            end
            end

            # def authenticate!
            #   resource  = mapping.to.find_for_database_authentication(authentication_hash)
            #   hashed = false

            #   if validate(resource){ hashed = true; resource.valid_password?(password) }
            #     remember_me(resource)
            #     resource.after_database_authentication
            #     success!(resource)
            #   end
            # end
        end
    end
end


Warden::Strategies.add(:nias_login, Devise::Strategies::NiasStrategy)