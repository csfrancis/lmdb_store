Gem::Specification.new do |s|
  s.name = 'lmdb_store'
  s.version = '0.0.1'
  s.summary = 'LMDB implementation of ActiveSupport::Store'
  s.description = <<-DOC
    This gem provides an ActiveSupport::Store implementation that is backed by an LMDB database.
  DOC
  s.homepage = 'https://github.com/csfrancis/lmdb_store'
  s.authors = 'Scott Francis'
  s.email   = 'scott.francis@shopify.com'
  s.license = 'MIT'

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'activesupport', ' >= 5'
  s.add_runtime_dependency 'lmdb', ' >= 0.5'

  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'pry', '~> 0.12.2'
end
