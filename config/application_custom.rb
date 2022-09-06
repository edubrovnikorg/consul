module Consul
  class Application < Rails::Application
    
    def secret_key_base 
      if Rails.env.test? || Rails.env.development? 
        secrets.secret_key_base || Digest::MD5.hexdigest(self.class.name) 
      else 
        validate_secret_key_base( 
          ENV["SECRET_KEY_BASE"] || credentials.secret_key_base || secrets.secret_key_base 
        ) 
      end 
    end 

  end
end
