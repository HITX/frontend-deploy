include_recipe 'application'

api_settings = node['api']
frontend_settings = node['frontend']

user 'deploy' do
  supports :manage_home => true
  home '/home/deploy'
  shell '/bin/bash'
  system true
end

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
        :api_port => api_settings['port'],
        :frontend_host => frontend_settings['hostname'],
        :frontend_port => frontend_settings['port'],
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

  nginx_load_balancer do
    only_if { node['roles'].include? 'internshyps_load_balancer' }
    application_port 8080
  end

  nodejs do
    only_if { node['roles'].include? 'internshyps_application_server' }
  end
end
