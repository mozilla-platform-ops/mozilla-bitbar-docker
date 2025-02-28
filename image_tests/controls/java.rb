# root@fdc33449fe30:/tmp# javac --version
# javac 17.0.14
# root@fdc33449fe30:/tmp# java --version
# openjdk 17.0.14 2025-01-21
# OpenJDK Runtime Environment (build 17.0.14+7-Ubuntu-122.04.1)
# OpenJDK 64-Bit Server VM (build 17.0.14+7-Ubuntu-122.04.1, mixed mode, sharing)

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
