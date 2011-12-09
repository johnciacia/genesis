require 'sinatra'
require 'json'
require 'yaml'

$config = YAML.load_file('config.yml')

post '/' do
  key = params[:key]
  if key == $config['server']['key']
    request = JSON.parse(params[:payload])
    project = request['repository']['name']
    system('cd ' + $config['projects'][project]['root'] + " && git pull")
  end
end
