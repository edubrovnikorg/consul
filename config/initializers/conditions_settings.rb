require 'onelogin/ruby-saml/settings'

# Adding support for Conditions element specifiet in the implementation specification by
# National Identification and Authentication System (NIAS) https://nias.gov.hr

OneLogin::RubySaml::Settings.class_eval do
    class << self
        attr_accessor :conditions
    end
end
