$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "river/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "river"
  s.version     = River::VERSION
  s.authors     = ["wykhuh"]
  s.email       = ["wykhuh@users.noreply.github.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of River."
  s.description = "TODO: Description of River."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"

  s.add_development_dependency "sqlite3"
end
