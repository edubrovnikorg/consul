require 'onelogin/ruby-saml/authrequest'
require "rexml/document"
require "onelogin/ruby-saml/logging"
require "onelogin/ruby-saml/saml_message"
require "onelogin/ruby-saml/utils"
require "onelogin/ruby-saml/setting_error"

# Overwrite of OneLogin::RubySaml::Authrequest.create_xml_document method to support SAML request specification by
# National Identification and Authentication System (NIAS) https://nias.gov.hr

OneLogin::RubySaml::Authrequest.class_eval do
    def create(settings, params = {})
        params = create_params(settings, params)
        params_prefix = (settings.idp_sso_service_url =~ /\?/) ? '&' : '?'
        saml_request = CGI.escape(params.delete("SAMLRequest"))
        request_params = "#{params_prefix}SAMLRequest=#{saml_request}"
        params.each_pair do |key, value|
            request_params << "&#{key.to_s}=#{CGI.escape(value.to_s)}"
        end
        raise SettingError.new "Invalid settings, idp_sso_service_url is not set!" if settings.idp_sso_service_url.nil? or settings.idp_sso_service_url.empty?
        @login_url = settings.idp_sso_service_url + request_params
    end

    def create_params(settings, params={})
        sign_algorithm = XMLSecurity::BaseDocument.new.algorithm(settings.security[:signature_method])

        request_doc = create_authentication_xml_doc(settings)
        request_doc.context[:attribute_quote] = :quote if settings.double_quote_xml_attribute_values
        request_doc.context[:prologue_quote] = :quote if settings.double_quote_xml_attribute_values
        request_doc.elements.delete("//*[name() = 'ds:Signature']");

        xml = '';
        request_doc.write(xml)

        Rails.logger.debug "============================== SAML REQUEST ===================================="
        Rails.logger.debug "#{xml}"
        Rails.logger.debug "============================== SAML REQUEST END ===================================="

        request =  deflate(xml) if settings.compress_request
        Rails.logger.debug "============================== SAML DEFLATE ===================================="
        Rails.logger.debug "DEFLATED = #{request}"
        Rails.logger.debug "============================== SAML DEFLATE END ===================================="
        base64_request = Base64.encode64(request).gsub(/\n/, "")
        Rails.logger.debug "============================== SAML base64 ===================================="
        Rails.logger.debug "B64 = #{base64_request}"
        Rails.logger.debug "============================== SAML base64 END ===================================="
        request_params = {"SAMLRequest" => base64_request}
        
        # The method expects :RelayState but sometimes we get 'RelayState' instead.
        # Based on the HashWithIndifferentAccess value in Rails we could experience
        # conflicts so this line will solve them.
        relay_state = params[:RelayState] || params['RelayState']
        relay_state = relay_state
        request_params['RelayState'] = relay_state

    
        if settings.security[:authn_requests_signed] && settings.security[:embed_sign] && settings.private_key
            request_params['SigAlg'] = settings.security[:signature_method]
            url_string = OneLogin::RubySaml::Utils.build_query(
                :type => 'SAMLRequest',
                :data => base64_request,
                :relay_state => request_params['RelayState'],
                :sig_alg => request_params['SigAlg']
            )
            signature = settings.get_sp_key.sign(sign_algorithm.new, url_string)
            byebug
            signature = Base64.encode64(signature)
            request_params['Signature'] = signature
        end

        request_params
    end
end