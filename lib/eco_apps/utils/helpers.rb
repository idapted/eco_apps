module Idapted
  module Helpers
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.helper_method :url_of
      base.extend SingletonMethods
    end

    module InstanceMethods

      # Get url of another app's resource.
      #
      # For example, if we need to have a link in self_study to scenario, we should do:
      # 1. in scenario's site_config.yml:
      #   api:
      #     url:
      #       show_scenario: admin/scenarios/:id
      # 2. then in self_study, we can call
      #   url_of(:scenario, :show_scenario, :id=>5) # return "/scenario/admin/scenarios/5"
      def url_of(app_name, url_key, options={})
        app = CoreService.app(app_name.to_s)
        app_url = YAML.load(app.url)
        app_url = app_url[Rails.env] if app_url.is_a?(Hash)
        
        api = YAML.load(app.api)
        begin
          url = api["url"][url_key.to_s] || ""
          options.each{|k,v| url = url.gsub(":#{k}", v.to_s)}
          params = options[:params]
          params = params.map{|t| "#{t.first}=#{t.last}"}.join("&") if params.instance_of?(Hash)
          [app_url, url.split("/").join("/")].join("/") + (params.blank? ? "" : "?#{params}")
        rescue Exception => e
          raise "#{url_key} of #{app_name} seems not configured correctly in #{app_name}'s site_config.yml"
        end
      end
      
    end

    module SingletonMethods
     
    end
  end
end

