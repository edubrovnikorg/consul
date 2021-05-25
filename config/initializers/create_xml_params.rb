require 'onelogin/ruby-saml/authrequest'
require "rexml/document"
require "onelogin/ruby-saml/logging"
require "onelogin/ruby-saml/saml_message"
require "onelogin/ruby-saml/utils"
require "onelogin/ruby-saml/setting_error"

# Overwrite of OneLogin::RubySaml::Authrequest.create_xml_document method to support SAML request specification by
# National Identification and Authentication System (NIAS) https://nias.gov.hr

OneLogin::RubySaml::Authrequest.class_eval do
    def create_params(settings, params={})
        sign_algorithm = XMLSecurity::BaseDocument.new.algorithm(settings.security[:signature_method])

        request_doc = create_authentication_xml_doc(settings)
        request_doc.context[:attribute_quote] = :quote if settings.double_quote_xml_attribute_values
        xml = Nokogiri::XML(request_doc.to_s, nil, 'utf-8')
        signed_doc = settings.get_sp_key.sign(sign_algorithm.new, xml.to_s)
        
        Rails.logger.debug "============================== SAML REQUEST ===================================="
        Rails.logger.debug "SAMLRequest/XML doc >> "
        Rails.logger.debug "#{xml.to_s}"
        Rails.logger.debug "============================== SAML REQUEST ===================================="

        request = deflate(signed_doc) if settings.compress_request
        base64_request = encode(request)
        request_params = {"SAMLRequest" => base64_request}

        # The method expects :RelayState but sometimes we get 'RelayState' instead.
        # Based on the HashWithIndifferentAccess value in Rails we could experience
        # conflicts so this line will solve them.
        request_params["RelayState"] = params[:RelayState] || params['RelayState']
    
        if settings.security[:authn_requests_signed] && !settings.security[:embed_sign] && settings.private_key
            request_params['SigAlg'] = settings.security[:signature_method]
            url_string = OneLogin::RubySaml::Utils.build_query(
                :type => 'SAMLRequest',
                :data => base64_request,
                :relay_state => request_params['RelayState'],
                :sig_alg => request_params['SigAlg']
            )
            signature = settings.get_sp_key.sign(sign_algorithm.new, url_string)
            request_params['Signature'] = encode(signature)
        end

        request_params
    end
end