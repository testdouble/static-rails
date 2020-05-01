require_relative "lib/static-rails/version"

Gem::Specification.new do |spec|
  spec.name = "static-rails"
  spec.version = StaticRails::VERSION
  spec.authors = ["Justin Searls"]
  spec.email = ["searls@gmail.com"]

  spec.summary = "Build & serve static sites (e.g. Jekyll, Hugo) from your Rails app"
  spec.homepage = "https://github.com/testdouble/static-rails"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|example)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 5.0.0"
  spec.add_dependency "rack-proxy", "~> 0.6"
end
