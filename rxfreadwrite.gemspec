Gem::Specification.new do |s|
  s.name = 'rxfreadwrite'
  s.version = '0.1.4'
  s.summary = 'Read and write files from remote locations ' +
      '(using the DFS protocol) as well as local.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rxfreadwrite.rb']
  s.add_runtime_dependency('rxfreader', '~> 0.1', '>=0.1.2')
  s.signing_key = '../privatekeys/rxfreadwrite.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/rxfreadwrite'
end
