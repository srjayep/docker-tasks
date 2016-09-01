control "api-gateway-1.0" do
  impact 0.7
  title "Test required dirs and files"

  describe command('ls /etc/api-gateway/') do
       its('exit_status') { should eq 1 } 
  end
describe file('/etc/api-gateway/api-gateway.conf') do
   it { should be_file }
end
end
