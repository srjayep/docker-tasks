load '../Rakefile.local' if File.exist?('../Rakefile.local')
require 'fileutils'
desc "Build a Docker container from this repo."
task :prepare_fixtures do
  git_type = ENV['GIT_TYPE']
  git_repo = ENV['GIT_REPO'].chomp.strip.split(/\//)
  FileUtils.rm_rf(git_repo[1]) if File.exist?(git_repo[1])
  if (git_type == 'public' || git_type == 'PUBLIC' ) 
      git_url = "https://github.com"
    elsif (git_type == 'private' || git_type == 'PRIVATE' )
      git_url = "https://git.corp.adobe.com"
    else 
      fail "ENV variable GIT_TYPE is not set, cannot proceed." 
  end
  sh %(git clone #{git_url}/#{git_repo[0]}/#{git_repo[1]})
end
