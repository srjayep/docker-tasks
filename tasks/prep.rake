load '../Rakefile.local' if File.exist?('../Rakefile.local')
desc "Build a Docker container from this repo."
task :prepare_fixtures do
  git_repo = ENV['GIT_REPO']
  sh %(git clone https://github.com/#{git_repo})
end
