require 'sinatra'
require 'json'
require 'config.rb'

post '/' do
  key = params[:key]
  if key == 'bGbfQKrMrbqaDdSkCiYYqlYwfdcNMAtn'
    request = JSON.parse(params[:payload])
    project = request['repository']['name']
    puts "Updating " + project
    system('cd ' + $projects[project] + " && git pull")
  end
end
