title 'check the shell environment'

describe bash("printenv") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /ADB_LIBUSB=0/ }
  # TODO: check for full path?
  its('stdout') { should match /ANDROID_SDK_ROOT/ }
  # TODO: check PATH?
end
