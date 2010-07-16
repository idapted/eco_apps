spec = Gem::Specification.new do |s| 
  s.name = "eco_apps"
  s.version = "0.0.1"
  s.author = "Lei Guo"
  s.email = "guolei@idapted.com"
  s.homepage = "http://gems.idapted.com/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Lib for idapted platform"
  %w{lib}.each{|folder|
    s.files += Dir["#{folder}/**/*"]
  }
  s.require_path = "lib"
  s.autorequire = "eco_apps"
  s.test_files = Dir["{spec}/**/*"]
end

# s.name and s.autorequire must be the same as file under lib
