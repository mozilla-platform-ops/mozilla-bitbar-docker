title "java checks"

source_bash_snippet = "source /root/.bashrc &&"

describe bash("#{source_bash_snippet} javac --version") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /17.0.14/ }
end

describe bash("#{source_bash_snippet} java --version") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /17.0.14/ }
end
