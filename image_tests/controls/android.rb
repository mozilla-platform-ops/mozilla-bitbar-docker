title "android checks"

path_env = [
  '/opt/android-sdk/platform-tools',
  '/opt/android-sdk/cmdline-tools/latest/bin',
  # older paths
  '/usr/local/sbin',
  '/usr/local/bin',
  '/usr/sbin',
  '/usr/bin',
  '/sbin',
  '/bin',
  '/builds/worker/bin',
  '/usr/local/bin',
  '/builds/worker/android-sdk-linux/platform-tools',
  '/builds/worker/android-sdk-linux/platform-tools/bin',
  '/builds/worker/android-sdk-linux/tools',
  '/builds/worker/android-sdk-linux/tools/bin',
].join(':')

describe bash("PATH=#{path_env} adb --version") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /Android Debug Bridge version 1.0.41/ }
end

describe bash("PATH=#{path_env} fastboot --version") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /fastboot version 35.0.2-12147458/ }
end

describe bash("PATH=#{path_env} sdkmanager --version") do
  its('exit_status') { should eq 0 }
  # its('stdout') { should match /24.3.4/ }
  its('stdout') { should match /7.0/ }
end

# test for profgen
describe bash("PATH=#{path_env} profgen --help") do
  its('exit_status') { should eq 0 }
end

# describe bash("PATH=#{path_env} avdmanager --version") do
#   its('exit_status') { should eq 0 }
# end

# describe bash("PATH=#{path_env} emulator -version") do
#   its('exit_status') { should eq 0 }
# end
