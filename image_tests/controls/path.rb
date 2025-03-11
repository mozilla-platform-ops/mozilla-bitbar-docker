# idea: source /root/.bashrc and then make sure vital tools are on the PATH

title "path checks"

source_bash_snippet = "source /root/.bashrc &&"

describe bash("#{source_bash_snippet} which adb") do
  its('exit_status') { should eq 0 }
end

describe bash("#{source_bash_snippet} which fastboot") do
  its('exit_status') { should eq 0 }
end

describe bash("#{source_bash_snippet} which sdkmanager") do
  its('exit_status') { should eq 0 }
end
