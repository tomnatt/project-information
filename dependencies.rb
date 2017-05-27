require 'httparty'

github_repos_url = 'https://api.github.com/users/tomnatt/repos'
response_json = HTTParty.get(github_repos_url).body

# Skip everything except ruby for now
repos = JSON.parse(response_json).map { |repo| repo['full_name'] if repo['language'] == 'Ruby' }
repos.reject!(&:nil?)

repos.each do |repo_name|
  libraries_url = "https://libraries.io/api/github/#{repo_name}/dependencies?api_key=#{ENV['LIBRARIES_API_KEY']}"

  response_json = HTTParty.get(libraries_url).body
  dependencies = JSON.parse(response_json)['dependencies']

  next unless dependencies

  puts repo_name
  printf "%-20s\t\t%s\t\t%s\n", 'dependency', 'current', 'latest'
  dependencies.each do |dep|
    next unless dep['filepath'] == 'Gemfile.lock' && dep['outdated']
    printf "%-20s\t\t%s\t\t%s\n", dep['project_name'], dep['requirements'], dep['latest_stable']
  end
  puts ''
end
