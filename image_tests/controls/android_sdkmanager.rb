title "android sdkmanager checks"

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

describe bash("PATH=#{path_env} sdkmanager --list_installed") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /build-tools\;33.0.0\w*|\w*33.0.0/ }
  its('stdout') { should match /cmdline-tools;7.0\w*|\w*7.0.0/ }
  its('stdout') { should match /platform-tools\w*|\w*35.0.2/ }
  its('stdout') { should match /platforms;android-33\w*|\w*3/ }
end
