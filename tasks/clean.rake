namespace :clean do
desc "Clean up artifacts and local Docker images"
task :images do
  if image.length > 0
   if containers.length > 0
    sh "docker rm -f #{containers}"
   else
    puts "No containers to clean"
   end
   sh "docker rmi -f #{images}"
  else
   puts "No images to clean"
   exit
  end
end

desc "Clean up local Docker containers"
task :containers do
  if container.length > 0
    sh "docker rm -f #{container}"
  else 
    puts "No containers to clean"
  end
end

def image
  `docker images | awk 'NR>1'|awk '{print $3}'|paste -sd ' ' -`
end

def container
  `docker ps -a | awk 'NR>1'|awk '{print $1}'|paste -sd ' ' -`
end

end
