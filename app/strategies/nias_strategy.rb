# class NiasStrategy < Warden::Strategies::Base
#     def valid?
#       params[:session_index].present?
#       params[:oib].present?
#     end
  
#     def authenticate!
#       user = User.first_or_initialize_for_nias(params)
  
#       if user
#         success!(user)
#       else
#         fail!('Invalid request')
#       end
#     end
#   end