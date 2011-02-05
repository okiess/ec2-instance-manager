# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ec2-instance-manager}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Oliver Kiessler"]
  s.date = %q{2011-02-05}
  s.default_executable = %q{ec2-instance-manager}
  s.description = %q{Launches EC2 instances for multiple AWS accounts}
  s.email = %q{kiessler@inceedo.com}
  s.executables = ["ec2-instance-manager"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".document",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/ec2-instance-manager",
    "config.yml.sample",
    "ec2-instance-manager.gemspec",
    "lib/ec2-instance-manager.rb",
    "lib/ec2-instance-manager/ec2_instance_manager.rb",
    "lib/ec2-instance-manager/launch.rb",
    "lib/ec2-instance-manager/output.rb",
    "lib/ec2-instance-manager/status.rb",
    "test/ec2-instance-manager_test.rb",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/okiess/ec2-instance-manager}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Simple EC2 Instance Manager}
  s.test_files = [
    "test/ec2-instance-manager_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<amazon-ec2>, [">= 0"])
    else
      s.add_dependency(%q<amazon-ec2>, [">= 0"])
    end
  else
    s.add_dependency(%q<amazon-ec2>, [">= 0"])
  end
end

