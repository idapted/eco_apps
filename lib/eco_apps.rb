require 'eco_apps/utils/idp_util'

def files(name)
  File.join(File.dirname(__FILE__),"eco_apps/files", name)
end

if Object.const_defined?("Rails")

  Idp::Util.copy(files("app_config.yml"), config_file = Rails.root.join("config/app_config.yml").to_s, false)

  APP_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "apps_config.yml")).merge(YAML.load_file(config_file))

  if APP_CONFIG["name"].blank?
    raise 'please set name in RAILS_ROOT/config/app_config.yml'
  end

  if (core_root = APP_CONFIG["core_root"]).blank?
    raise 'please set core_root in GEMS_ROOT/eco_apps/lib/apps_config.yml or RAILS_ROOT/config/app_config.yml'
  end

  CORE_ROOT = (core_root.is_a?(Hash) ? core_root[Rails.env] : core_root)
  if not CORE_ROOT =~ Regexp.new("http://")
    raise 'core_root must begin with http://'
  end

  require 'eco_apps/core_service'
  require 'eco_apps/acts_as_readonly'

  require 'eco_apps/extensions/active_resource'

  require 'eco_apps/utils/helpers'

  ActionController::Base.send(:include, Idapted::Helpers)
  ActiveRecord::Base.send(:include, Idapted::ActsAsReadonly)

  CoreService.reset_config unless Rails.env == "test"

end
