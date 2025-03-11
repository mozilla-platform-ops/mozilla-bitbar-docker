title "android sdkmanager checks"

source_bash_snippet = "source /root/.bashrc &&"

describe bash("#{source_bash_snippet} sdkmanager --list_installed") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /build-tools\;35.0.1\w*|\w*35.0.1/ }
  its('stdout') { should match /platform-tools\w*|\w*35.0.2/ }
  its('stdout') { should match /platforms;android-33\w*|\w*3/ }
end
