devise_for :users, controllers: {
                     registrations: "users/registrations",
                     sessions: "users/sessions",
                     confirmations: "users/confirmations",
                     omniauth_callbacks: "users/omniauth_callbacks"
                   }
                   
devise_scope :user do
  scope "users", controller: 'users/saml_sessions' do
    get :index, path: "nias", as: :nias_index
    get :sson, path: "nias/login", as: :nias_login
    post :auth, path: "nias/auth", as: :user_sso_session
    post :destroy, path: "nias/logout", as: :destroy_user_sso_session
    get :ssout, path: "nias/sign_out", as: :nias_logout
    post :finish_sign_up, path: "nias/authorize", as: :nias_authorize
  end
end



devise_scope :user do
  patch "/user/confirmation", to: "users/confirmations#update", as: :update_user_confirmation
  get "/user/registrations/check_username", to: "users/registrations#check_username"
  get "users/sign_up/success", to: "users/registrations#success"
  get "users/registrations/delete_form", to: "users/registrations#delete_form"
  delete "users/registrations", to: "users/registrations#delete"
  get :finish_signup, to: "users/registrations#finish_signup"
  patch :do_finish_signup, to: "users/registrations#do_finish_signup"
end

devise_for :organizations, class_name: "User",
           controllers: {
             registrations: "organizations/registrations",
             sessions: "devise/sessions"
           },
           skip: [:omniauth_callbacks]

devise_scope :organization do
  get "organizations/sign_up/success", to: "organizations/registrations#success"
end
