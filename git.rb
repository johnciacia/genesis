require 'sinatra'
require 'json'

post '/' do
  key = params[:key]
  if key == 'bGbfQKrMrbqaDdSkCiYYqlYwfdcNMAtn'
    project_dir = '/Users/john/htdocs/'

    request = JSON.parse(params[:payload])
    project = request['repository']['name']
    
    out = `(cd #{project_dir}#{project} && git pull)`
    puts out
  end
end