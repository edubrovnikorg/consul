# patch Net::HTTP to support extra_chain_cert
class Net::HTTP
  SSL_IVNAMES << :@extra_chain_cert unless SSL_IVNAMES.include?(:@extra_chain_cert)
  SSL_ATTRIBUTES << :extra_chain_cert unless SSL_ATTRIBUTES.include?(:extra_chain_cert)

  attr_accessor :extra_chain_cert
end

class MupApiController < ApplicationController
  skip_authorization_check :only => :show

  def show
    mup_api   
  end

  # def faraday
  #   ## deleted
  # else

  private
    def mup_api 
      mup_private_key_pass = "#{Rails.application.secrets.mup_private_key_pass}"
      mup_private_key = "#{Rails.root}#{Rails.application.secrets.mup_private_key}"
      mup_public_key = "#{Rails.root}#{Rails.application.secrets.mup_public_key}"
      mup_ca_cert = "#{Rails.root}#{Rails.application.secrets.mup_ca}"
      mup_ca_path = "#{Rails.root}#{Rails.application.secrets.mup_ca_path}"

      pxf = OpenSSL::PKCS12.new(File.binread(mup_private_key), mup_private_key_pass)
      cert = OpenSSL::X509::Certificate.new(File.binread(mup_public_key))
      
      # openssl options
      OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version]=nil
      options = {
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE,
        cert: pxf.certificate,
        key: pxf.key,
        ca_path: mup_ca_path,
        ca_file: mup_ca_cert,
        ssl_version: :TLSv1_2
      }
      logger.debug "/////////////////// AUTH MUP HTTP START ////////////////////////"
      logger.debug "#{options}"

      # http call
      uri = URI("https://lsu.test.service.mup.hr:9001/FizickaOsobaService.svc?")
      
      http = Net::HTTP.start(uri.host, uri.port, options) do |http|
        request = Net::HTTP::Get.new uri
        response = http.request request
        @response = response
        logger.debug "AUTH MUP: #{response.body}"
      end

      logger.debug "/////////////////// AUTH MUP ENDED ////////////////////////"
    end

    def nias_sign_in
      nias = "#{Rails.root}#{Rails.application.secrets.nias_bin}"
      fina_root = "#{Rails.root}#{Rails.application.secrets.fina_root}"
      fina_intermediate = "#{Rails.root}#{Rails.application.secrets.fina_intermediate}"
      test_niasap = "#{Rails.root}#{Rails.application.secrets.test_niasap}"
      test_nias = "#{Rails.root}#{Rails.application.secrets.test_nias}"
      
      local_cert_path = "#{Rails.root}#{Rails.application.secrets.local_cert}"

      logger.debug "/////////////////// AUTH NIAS ENDED ////////////////////////"
    end

    def nias_callback

    end
end
