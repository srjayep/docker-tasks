control "9-2-5" do
  impact 1
  title "Should contains users redis and nginix-api-gaeway"
  desc "Should contains users redis and nginix-api-gaeway"
  describe passwd do
    its('users') { should include 'redis' }
    its('users') { should include 'nginx-api-gateway' }
  end
end
