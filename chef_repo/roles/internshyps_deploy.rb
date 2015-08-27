name 'internshyps_deploy'
description 'For deploying to an already bootstrapped webserver node'

settings = Chef::EncryptedDataBagItem.load('config', 'config_1')
debug = settings['DEBUG']
domain = settings['DOMAIN']
app_name = settings['APP_NAME']
repo = settings['REPO']
github_user = settings['GITHUB_USER']
github_deploy_key = settings['GITHUB_DEPLOY_KEY']
ec2_host = settings['EC2_HOST']
api_hostname = settings['API_HOSTNAME']
api_port = settings['API_PORT']
api_client_id = settings['API_CLIENT_ID']
api_client_secret = settings['API_CLIENT_SECRET']
frontend_hostname = settings['FRONTEND_HOSTNAME']
frontend_port = settings['FRONTEND_PORT']

default_attributes(
  'app_name' => app_name,
  'repo' => "#{github_user}/#{repo}",
  'github_deploy_key' => github_deploy_key.gsub(/\\n/, "\n"),
  'ec2_host' => ec2_host,
  'api' => {
    'hostname' => api_hostname,
    'port' => api_port,
    'client_id' => api_client_id,
    'client_secret' => api_client_secret
  },
  'frontend' => {
    'hostname' => frontend_hostname,
    'port' => frontend_port
  }
)

run_list 'recipe[internshyps::deploy]'
