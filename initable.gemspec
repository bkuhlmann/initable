# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "initable"
  spec.version = "0.5.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/initable"
  spec.summary = "An automatic object initializer."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/initable/issues",
    "changelog_uri" => "https://alchemists.io/projects/initable/versions",
    "homepage_uri" => "https://alchemists.io/projects/initable",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Initable",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/initable"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.4"
  spec.add_dependency "marameters", "~> 4.1"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
