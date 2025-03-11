title "android checks"

source_bash_snippet = "source /root/.bashrc &&"

describe bash("#{source_bash_snippet} adb --version") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /Android Debug Bridge version 1.0.41/ }
end

describe bash("#{source_bash_snippet} fastboot --version") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /fastboot version 35.0.2-12147458/ }
end

describe bash("#{source_bash_snippet} sdkmanager --version") do
  its('exit_status') { should eq 0 }
  # its('stdout') { should match /24.3.4/ }
  its('stdout') { should match /12.0/ }
end

# test for profgen
describe bash("#{source_bash_snippet} profgen --help") do
  its('exit_status') { should eq 0 }
end

# check cmdline-tools version
describe file('/builds/worker/android-sdk-linux/cmdline-tools/latest/source.properties') do
  its('content') { should match /Pkg.Revision=12.0/ }
end
