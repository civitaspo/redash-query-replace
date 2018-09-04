
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "redash/query/replace/version"

Gem::Specification.new do |spec|
  spec.name          = "redash-query-replace"
  spec.version       = Redash::Query::Replace::VERSION
  spec.authors       = ["Civitaspo"]
  spec.email         = ["civitaspo@gmail.com"]

  spec.summary       = %q{Command Line Tool to replace queries on Redash about query, datasource, and so on.}
  spec.description   = %q{Command Line Tool to replace queries on Redash about query, datasource, and so on.}
  spec.homepage      = "https://github.com/civitaspo/redash-query-replace"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "thor"
  spec.add_dependency "dotenv"
  spec.add_dependency "rest-client"
  spec.add_dependency "hashie"
end
