class CustomFailure < Devise::FailureApp
    # include ActionController::UrlWriter
    def route(scope)
      :root_path
    end
  end