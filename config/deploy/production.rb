set :branch, ENV["branch"] || 'consul-api'
set :ssh_options, {
  user: "deploy",
  forward_agent: false,
  keys: '~/.ssh/consul_matija',
  auth_methods: %w(publickey password)
}

server deploysecret(:server1), user: deploysecret(:user), roles: %w[web app db importer cron background]
#server deploysecret(:server2), user: deploysecret(:user), roles: %w(web app db importer cron background)
#server deploysecret(:server3), user: deploysecret(:user), roles: %w(web app db importer)
#server deploysecret(:server4), user: deploysecret(:user), roles: %w(web app db importer)
