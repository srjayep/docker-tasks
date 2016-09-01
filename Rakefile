require "bundler/gem_tasks"

$LOAD_PATH << "docker-tasks/docker/tasks/lib"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development, :test)
Dotenv.load(".common.env", ".env")

require "docker/tasks"
# Create/Modify Rakefile.local to define arbitrary ENVs
#require 'pathname'
#path = Pathname.new("Rakefile.local")
#eval(path.read) if path.exist?

#Dir.glob('../common/lib/tasks/*.rake').each { |r| load r }
Docker::Tasks.init!("https://registry.hub.docker.com")
#Docker::Tools.init!("registry.hub.docker.com", "https://registry.hub.docker.com/pothus0718/pothua")
