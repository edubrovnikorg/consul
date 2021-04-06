#!/usr/bin/env puma

_load_from File.expand_path("../defaults.rb", __FILE__)

port        ENV.fetch("PORT") { 3001 }
environment "production"

# # Add ssl certificate
server_key = "#{Rails.application.secrets.server_key}"
server_crt = "#{Rails.application.secrets.server_crt}"

# To be able to use rake etc
ssl_bind '127.0.0.1', 3000, {
key: server_key,
cert: server_crt,
# verify_mode: 'none'
}