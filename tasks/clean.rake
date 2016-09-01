desc "Clean up artifacts and local Docker images"
task :clean do
  if images.length > 0
    sh "docker rmi -f #{images}"
  end
end

def images
  `docker images | awk ' !x[$0]++' | awk 'NR>1' |paste -sd ' ' -`
end

#desc "Clean Docker container from this repo"
#task :clean do
#sh %(docker rm -v $(docker ps --filter status=exited -q)
#sh %(docker rm -v $(docker ps --filter status=exited -q)
#sh %(docker rmi $(docker images --filter "dangling=true" -q --no-trunc))
#end
