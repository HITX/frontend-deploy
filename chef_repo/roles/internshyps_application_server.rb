name 'internshyps_application_server'
description 'A node hosting a Node.js servering serving ReactJS webapp'

settings = Chef::EncryptedDataBagItem.load('config', 'config_1')
debug = settings['DEBUG']
domain = settings['DOMAIN']
app_name = settings['APP_NAME']
repo = settings['REPO']
github_user = settings['GITHUB_USER']
github_deploy_key = settings['GITHUB_DEPLOY_KEY']
ec2_host = settings['EC2_HOST']

default_attributes(
  'app_name' => app_name,
  'repo' => "#{github_user}/#{repo}",
  'github_deploy_key' => github_deploy_key.gsub(/\\n/, "\n"),
  'ec2_host' => ec2_host
)

run_list 'recipe[internshyps]'
