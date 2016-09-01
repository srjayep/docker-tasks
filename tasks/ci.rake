
namespace :ci do

  desc "Build the tier and publish remotely"
  task :tier do
    Rake::Task["test"].invoke
    Rake::Task["publish:remote"].invoke
  end

end

desc "Build and Publish artifacts remotely (default)"
task :ci => [ 'ci:tier' ]
