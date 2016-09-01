control 'world-1.0' do
 impact 1.0
 title 'Hello world'
 desc "Text should match 'Hello world'"
 describe file ('hello.txt') do
  its ('content') {should match 'Hello world'}
 end
end
 
