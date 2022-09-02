# copyright: 2018, The Authors

title "python3 checks"

describe bash('pip3 list | grep zstandard') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /zstandard.*0.11.1/ }
end