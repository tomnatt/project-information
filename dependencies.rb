require 'httparty'
require 'nitlink/response'

# github_repos_url = 'https://api.github.com/users/tomnatt/repos?per_page=10&page=1'
github_repos_url = 'https://api.github.com/orgs/alphagov/repos?per_page=100&page=1'
if ENV['GITHUB_API_TOKEN']
  github_repos_url += "&access_token=#{ENV['GITHUB_API_TOKEN']}"
end

repos = []

loop do
  response = HTTParty.get(github_repos_url)
  # Skip everything except ruby for now
  repos += JSON.parse(response.body).map { |repo| repo['full_name'] if repo['language'] == 'Ruby' }
  # repos += JSON.parse(response.body)

  break if response.links.by_rel('next').nil?

  github_repos_url = response.links.by_rel('next').target
end

repos.reject!(&:nil?)

# While testing to avoid hammering libraries.io
repos = repos.first(5)

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
