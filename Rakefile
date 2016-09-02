require "bundler/gem_tasks"

#$LOAD_PATH << "docker-tasks/docker/tasks/lib"
$LOAD_PATH << "./lib"
require "rubygems"
require "docker/tasks"
require "bundler/setup"
Bundler.require(:default, :development, :test)
Dotenv.load(".common.env", ".env")

#Dir.glob('../common/lib/tasks/*.rake').each { |r| load r }
Docker::Tasks.init!("https://registry.hub.docker.com")
