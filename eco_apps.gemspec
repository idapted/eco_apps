spec = Gem::Specification.new do |s| 
  s.name = "eco_apps"
  s.version = "0.1"
  s.author = "Idapted Ltd"
  s.email = "tech-team@idapted.com"
  s.homepage = "http://developer.idapted.com/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Eco Apps enables you to develop an eco-system of Rails applications that function as a single system."
  %w{lib}.each{|folder|
    s.files += Dir["#{folder}/**/*"]
  }
  s.require_path = "lib"
  s.autorequire = "eco_apps"
  s.test_files = Dir["{spec}/**/*"]
  s.add_dependency("netaddr")
end