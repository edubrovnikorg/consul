set :branch, ENV["branch"] || 'consul-api'

server deploysecret(:server), user: deploysecret(:user), roles: %w[web app db importer cron background]

