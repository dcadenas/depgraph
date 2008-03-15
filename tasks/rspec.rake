begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  require 'spec'
end
begin
  require 'spec/rake/spectask'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end

desc "Run the specs under spec/unittests"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ['--options', "spec/unit_spec.opts"]
  t.spec_files = FileList['spec/unittests/*_spec.rb']
end

desc "Run the specs under spec/integrationtests"
Spec::Rake::SpecTask.new('ispec') do |t|
  t.spec_opts = ['--options', "spec/integration_spec.opts"]
  t.spec_files = FileList['spec/integrationtests/*_spec.rb']
end

desc "Run the specs under spec"
Spec::Rake::SpecTask.new('allspec') do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--text-summary']
end
