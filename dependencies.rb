require 'httparty'

url = 'https://libraries.io/api/github/tomnatt/monzoapp/dependencies?api_key=' + ENV['LIBRARIES_API_KEY']

response_json = HTTParty.get(url).body
dependencies = JSON.parse(response_json)['dependencies']

printf "%-20s\t\t%s\t\t%s\n", 'dependency', 'current', 'latest'
dependencies.each do |dep|
  next unless dep['filepath'] == 'Gemfile.lock' && dep['outdated']
  printf "%-20s\t\t%s\t\t%s\n", dep['project_name'], dep['requirements'], dep['latest_stable']
end
