title "android checks"

describe bash('PATH=$PATH:/builds/worker/android-sdk-linux/platform-tools adb --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /Android Debug Bridge version 1.0.41/ }
end
