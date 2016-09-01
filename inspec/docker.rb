control 'docker-1' do
  title 'check that container are running'
  # get inspec data
  ids = command('docker ps --format "{{.ID}}"').stdout.split
  ids.each do |id|
    # get data
    raw = command("docker inspect #{id}").stdout
    # hack, json resource need to be able to load content from string properly
    info = json('').parse(raw)
    # check that each container is running
    describe info[0] do
      # should be its("State.Running") { should cmp 'Running'}
      its(['State','Running']) { should cmp true}
    end
    describe command (command('/etc/api-gateway').exist?)
      it { should eq true }
  end
end
