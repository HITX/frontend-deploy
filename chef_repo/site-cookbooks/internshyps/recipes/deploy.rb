include_recipe 'application'

api_settings = node['api']

puts 'TEST PRINTOUT:'
puts api_settings
puts api_settings['hostname']

application 'internshyps' do
  path '/srv/internshyps'
  owner 'deploy'
  group 'nogroup'
  repository "git@github.com:#{node.repo}.git"
  revision 'master'
  deploy_key node['github_deploy_key']
  environment 'NODE_ENV' => 'production', 'HOME' => '/home/deploy'
  migrate true
  migration_command './node_modules/.bin/gulp'
  symlink_before_migrate({
    'config/app.config.js' => 'config/app/config.js',
    'config/server.config.js' => 'config/server/config.js'
  })

  before_migrate do
    directory "#{new_resource.path}/shared/config" do
      recursive true
      action :create
    end

    template "#{new_resource.path}/shared/config/app.config.js" do
      source 'app.config.js.erb'
      cookbook 'internshyps'
      owner new_resource.owner
      group new_resource.group
      mode '0644'
      variables(
        :api_host => api_settings['hostname'],
        :api_port => api_settings['port']
      )
    end

    template "#{new_resource.path}/shared/config/server.config.js" do
      source 'server.config.js.erb'
      cookbook 'internshyps'
      owner new_resource.owner
      group new_resource.group
      mode '0644'
      variables(
        :client_id => api_settings['client_id'],
        :client_secret => api_settings['client_secret']
      )
    end
  end

  nodejs do
    only_if { node['roles'].include? 'internshyps_deploy' }
  end
end
