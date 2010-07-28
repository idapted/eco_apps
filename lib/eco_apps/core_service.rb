class CoreService < ActiveResource::Base
  self.site = MASTER_APP_URL

  class << self
    def reset_config
      options = {
        :name => APP_CONFIG["name"],
        :url => APP_CONFIG["url"],
        :api => APP_CONFIG["api"],
        :database => YAML.load_file(Rails.root.join("config/database.yml"))}

      if in_master_app?
        app = App.find_or_create_by_name(options[:name])
        app.update_attributes(options)
      else
        begin
          self.post(:reset_config, :app => options)
        rescue Exception => e
          raise "master_app_url is '#{MASTER_APP_URL}', it's illegal or can not be reached!"
        end
      end
    end

    def app(app_name)
      app_name = app_name.to_s
      if in_master_app?
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

    def in_master_app?
      Object.const_defined?("IN_ECO_APPS_MASTER") and IN_ECO_APPS_MASTER
    end
  end

end
