require 'sinatra'
require 'json'
require 'yaml'

$config = YAML.load_file('config.yml')

post '/' do
  key = params[:key]
  if key == $config['server']['key']
    request = JSON.parse(params[:payload])
    project = request['repository']['name']
    puts "Updating " + project
    system('cd ' + $projects[project] + " && git pull")
  end
end
