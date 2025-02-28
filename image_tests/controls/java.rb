title "java checks"

path_env = [
  '/usr/bin',
  '/bin',
  '/usr/local/sbin',
  '/usr/local/bin',
  '/usr/sbin',
  '/sbin',
].join(':')

describe bash("PATH=#{path_env} javac --version") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /17.0.14/ }
end

describe bash("PATH=#{path_env} java --version") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /17.0.14/ }
end
