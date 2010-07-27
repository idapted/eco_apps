require 'eco_apps/utils/idp_util'

def files(name)
  File.join(File.dirname(__FILE__),"eco_apps/files", name)
end

if Object.const_defined?("Rails")

  Idp::Util.copy(files("app_config.yml"), config_file = Rails.root.join("config/app_config.yml").to_s, false)

  APP_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "platform_config.yml")).merge(YAML.load_file(config_file))

  if APP_CONFIG["name"].blank?
    raise 'please set name in RAILS_ROOT/config/app_config.yml'
  end

  if (master_app_url = APP_CONFIG["master_app_url"]).blank?
    raise 'Please set master_app_url in GEMS_ROOT/eco_apps/lib/platform_config.yml or RAILS_ROOT/config/app_config.yml'
  end

  MASTER_APP_URL = (master_app_url.is_a?(Hash) ? master_app_url[Rails.env] : master_app_url)
  if not MASTER_APP_URL =~ Regexp.new("http://")
    raise 'master_app_url must begin with http://'
  end

  puts "============ #{Rails.env} ==============="

  if Rails.env == "production"
    require 'netaddr'
    raise "intranet_ip is not identified!" if (ips = APP_CONFIG["intranet_ip"]).blank?
    INTRANET_IP = [ips].flatten.map{|ip|NetAddr::CIDR.create(ip)}
  end

  require 'eco_apps/core_service'
  require 'eco_apps/acts_as_readonly'

  require 'eco_apps/extensions/active_resource'

  require 'eco_apps/utils/helpers'

  ActionController::Base.send(:include, Idapted::Helpers)
  ActiveRecord::Base.send(:include, Idapted::ActsAsReadonly)

  CoreService.reset_config unless Rails.env == "test"

end