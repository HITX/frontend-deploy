user 'deploy' do
  system true
  shell '/bin/false'
end

# package 'upstart'
# package 'upstart-sysv'

application 'internshyps' do
  path '/srv/internshyps'
  owner 'deploy'
  group 'nogroup'
  repository "git@github.com:#{node.repo}.git"
  revision 'master'
  deploy_key node['github_deploy_key']

  nginx_load_balancer do
    only_if { node['roles'].include? 'internshyps_load_balancer' }
    application_port 8080
    # static_files '/static' => 'static'
  end

  nodejs do
    only_if { node['roles'].include? 'internshyps_application_server' }
    entry_point 'server.js'
  end
end
