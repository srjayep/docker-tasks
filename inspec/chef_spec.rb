control "cis-1-2-1" do
  impact 1.0
 title "Verify Correct Chef version 12.5.1 is Installed (Scored)"
 describe 'Default chef version' 
  describe command('chef -v') do
    its('stdout') { should match /#{Regexp.escape('12.5.1')}/ }
  end
end

