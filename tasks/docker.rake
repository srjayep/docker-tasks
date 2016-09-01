namespace :docker do
load '../Rakefile.local' if File.exist?('../Rakefile.local')
  force_tag   = (ENV["FORCE_TAG"].to_i != 0) ? "-f " : ""
    dock_reg = ENV['DOCKER_REGISTRY'] || "api-platform-docker-release.dr-uw2.adobeitc.com"
    dock_tag_1 = "snapshot-`date +'%Y%m%d-%H%M'`"
    dock_tag_2 = `echo "#{dock_tag_1}"`
    dock_tag = ENV['DOCKER_TAG'] || "#{dock_tag_2}"
    dock_repo= ENV['DOCKER_REPO'] || "#{Docker::Tasks.full_name}"

  desc "Build a Docker container from this repo.  "\
    "Use FORCE_BUILD=1 to bypass layer caching."
  task :build do
    repo_part = ENV['GIT_REPO'].chomp.strip.split(/\//)
    force_rebuild = (ENV["FORCE_BUILD"].to_i != 0) ? "--no-cache=true" : ""
    if File.exist?("Dockerfile")
      dest = "."
    elsif File.exist?("context/Dockerfile")
      dest = "context"
    elsif 
      dest = "#{repo_part[1]}"
    else
      fail "Didn't find a Dockerfile in project root, or context/, cannot proceed."
    end
    sh %(docker build #{force_rebuild} -t #{dock_repo} #{dest})
  end
 
    puts "docker tag container#{Docker::Tasks.container}"
  desc "Tag a Docker container from this repo.  Uses VERSION or pom.xml to infer version,"\
    " and accepts FORCE_TAG=1 to forcibly re-tag locally."
  task :tag do
    force_tag   = (ENV["FORCE_TAG"].to_i != 0) ? "-f " : ""
    #sh %(docker tag #{force_tag} #{dock_repo} #{dock_reg}/#{dock_repo}:#{dock_tag})
    sh %(docker tag #{force_tag} #{dock_repo} #{dock_repo}:#{dock_tag})
    
  end
  desc "Push the recently tagged Docker container from this repo.  Uses VERSION or pom.xml to"\
    " infer version, and accepts FORCE_PUSH=1 to forcibly overwrite a tag on the registry."
  task :push do
    sh %(docker push #{dock_reg}/#{dock_repo}:#{dock_tag})
  end

  desc "Build Docker image for release, tag it, push it to registry.  Must be performed"\
    " immediately after a release build! OR use RELEASE_VERSION=<version>"\
    " to overwrite tag to check out"
  task :release do
    release_tag     = `git tag --list --points-at HEAD^1`.strip
    release_version = release_tag.split(%r{/}).last || (ENV["RELEASE_VERSION"].strip if ENV["RELEASE_VERSION"])
    if release_version.nil? && ENV["RELEASE_VERSION"].nil?
      fail "Tag not found and RELEASE_VERSION is empty. Are you sure this is performed immediately"\
      " after release build? \nIf not be sure to specify RELEASE_VERSION for tag to release from."
    end
    Docker::Tasks.override_version = release_version
    puts "Assembling and Releasing version: #{release_version}"
    begin
      sh "git checkout #{release_tag}"
      %i(docker:build docker:tag docker:push).each do |subtask|
        task(subtask).execute
      end
    ensure
      # Try to return to the branch the user was on before we started screwing with their state.
      sh "git checkout -"
    end
  end
end
