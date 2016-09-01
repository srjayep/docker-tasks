control "cis-2-1-1" do
  impact 1.0
  title "2.1.1 Remove telnet-server (Scored)"
  desc "The telnet package contains the telnet client, which allows users to start connections to other systems via the telnet protocol."
describe command('ps -ef|grep api-gateway-zmq-adaptor|grep -v grep') do
  its('stdout') { should match /api-gateway-zmq-adaptor/ }
end

describe command('ps -ef|grep api-gateway-config-supervisor|grep -v grep') do
  its('stdout') { should match /api-gateway-config-supervisor/ }
end

describe command('ps -ef|grep init-container.sh|grep -v grep') do
  its('stdout') { should match /init-container.sh/ }
end

end
