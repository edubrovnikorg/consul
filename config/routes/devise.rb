devise_for :users, controllers: {
                     registrations: "users/registrations",
                     sessions: "users/sessions",
                     confirmations: "users/confirmations",
                     omniauth_callbacks: "users/omniauth_callbacks"
                   }
                   
devise_scope :user do
  scope "users", controller: 'users/saml_sessions' do
    get :show, path: "nias/authorize", as: :nias_index
    get :sson, path: "nias/login", as: :nias_login
    post :auth, path: "nias/auth", as: :user_sso_session
    get :ssout, path: "nias/logout_request", as: :nias_logout
    post :finish_sign_up, path: "nias/finish", as: :nias_user_session
    get :finish_sign_out, path: "nias/sign_out", as: :nias_destroy_user_session
    post :after_initiate_logout, path: "nias/logout"
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
