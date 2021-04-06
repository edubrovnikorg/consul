# Puma can serve each request in a thread from an internal thread pool.
# Default is set to 5 threads for minimum and maximum, matching the
# default thread size of Active Record.
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

port        ENV.fetch("PORT") { 3001 }
environment "development"

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# # Add ssl certificate
server_key = "#{Rails.application.secrets.server_key}"
server_crt = "#{Rails.application.secrets.server_crt}"

# To be able to use rake etc
ssl_bind '127.0.0.1', 3000, {
key: server_key,
cert: server_crt,
# verify_mode: 'none'
}