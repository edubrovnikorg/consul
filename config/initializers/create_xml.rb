require 'onelogin/ruby-saml/authrequest'
require "rexml/document"
require "onelogin/ruby-saml/logging"
require "onelogin/ruby-saml/saml_message"
require "onelogin/ruby-saml/utils"
require "onelogin/ruby-saml/setting_error"

# Overwrite of OneLogin::RubySaml::Authrequest.create_xml_document method to support SAML request specification by
# National Identification and Authentication System (NIAS) https://nias.gov.hr

OneLogin::RubySaml::Authrequest.class_eval do
      def create_xml_document(settings)
        time = Time.now.utc
        exp_time = time + 84600
        time = time.strftime("%Y-%m-%dT%H:%M:%SZ")
        exp_time = exp_time.strftime("%Y-%m-%dT%H:%M:%SZ")

        request_doc = XMLSecurity::Document.new()
        request_doc << REXML::XMLDecl.new("1.0", "utf-8")

        root = request_doc.add_element "AuthnRequest", { 
            "xmlns" => "urn:oasis:names:tc:SAML:2.0:protocol",
            "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema", 
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        }
        root.attributes['ID'] = uuid
        root.attributes['Version'] = "2.0"
        root.attributes['IssueInstant'] = time
        root.attributes['Destination'] = settings.idp_sso_service_url unless settings.idp_sso_service_url.nil? or settings.idp_sso_service_url.empty?
        root.attributes['ProtocolBinding'] = settings.protocol_binding unless settings.protocol_binding.nil?
        root.attributes["AssertionConsumerServiceURL"] = settings.assertion_consumer_service_url

        # Issuer
        issuer = root.add_element "Issuer", { 
          "Format" => "urn:oasis:names:tc:SAML:1.1:nameid-format:entity", 
          "xmlns" => "urn:oasis:names:tc:SAML:2.0:assertion"
        }
        issuer.text = settings.issuer

        # Name ID Policy
        root.add_element "NameIDPolicy", { "Format" => settings.name_identifier_format }

        # Conditions
        conditions = root.add_element "Conditions", {
          "NotBefore"     => time,
          "NotOnOrAfter"  => exp_time,
          "xmlns"         => "urn:oasis:names:tc:SAML:2.0:assertion"
        }
        conditions.add_element "OneTimeUse"
        # conditions.add_element "Condition", {
        #     "xmlns:q1"                          => "http://nias.eid.com.hr/2012/07/saml20Extension",
        #     "xsi:type"                          => "q1:NiasConditionType",
        #     "MinAuthenticationSecurityLevel"    => "1"
        # }

        # Return request
        request_doc
      end
end
