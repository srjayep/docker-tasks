control 'basic-1' do
  impact 1.0
  title '/etc should be a directory'
  describe file('/etc') do
    it { should be_directory } 
  end
end


