$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "requests/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "requests"
  s.version     = Requests::VERSION
  s.authors     = ["Kevin Reiss"]
  s.email       = ["kevin.reiss@gmail.com"]
  s.homepage    = "http://github.com/pulibrary/requests"
  s.summary     = "Request Utilities for PUL Library."
  s.description = "Library Material Requests at Princeton University Library."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
end
