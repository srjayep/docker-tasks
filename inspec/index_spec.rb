control "cis-1-2-1" do
  impact 1.0
 title "Verify Correct for Splunk stage env (Scored)"
 describe 'Default chef version' 
  describe file('/opt/splunkforwarder/etc/system/local/inputs.conf') do
    its('content') { should match /index = adobeio_stage/ }
  end
end

