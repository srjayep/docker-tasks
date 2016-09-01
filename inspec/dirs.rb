control "dir-2-1-1" do
  impact 1.0
  title "2.1.1 Directories exist (Scored)"
  desc "The directories contain important gateway config should exist"
describe directory('/etc/api-gateway/conf.d') do
  it { should be_directory }
end
end
