class CoreService < ActiveResource::Base
  self.site = CORE_ROOT
  self.timeout= 30

  class << self
    def reset_config
      options = {
        :name => APP_CONFIG["name"],
        :url => APP_CONFIG["url"],
        :api => APP_CONFIG["api"],
        :database => YAML.load_file(Rails.root.join("config/database.yml"))}

      if in_core_app?
        app = App.find_or_create_by_name(options[:name])
        app.update_attributes(options)
      else
        begin
          self.post(:reset_config, :app => options)
        rescue Exception => e
          raise "core_root is #{CORE_ROOT}, it's illegal or can not be reached!"
        end
      end
    end

    def app(app_name)
      app_name = app_name.to_s
      if in_core_app?
        obj = App.find_by_name(app_name)
      else
        unless Rails.env == "production" or APP_CONFIG[Rails.env].blank? or
          (local = APP_CONFIG[Rails.env][app_name]).blank?
          return self.new(:name => local["name"], :url => local["url"],
            :api => YAML.dump(local["api"]), :database => (local["database"].blank? ? nil : YAML.dump(local["database"])))
        end
        obj = CoreService.find(app_name)
      end
      
      return obj if (!obj.blank? and obj.attributes["error"].blank?)
      raise("#{app_name} doesn't exist") 
    end

    def in_core_app?
      Object.const_defined?("CoreServicesController") and Object.const_defined?("AppMigration")
    end
  end

end
