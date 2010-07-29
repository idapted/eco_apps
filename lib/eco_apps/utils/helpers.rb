module Idapted
  module Helpers
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.helper_method :url_of
      base.extend SingletonMethods
    end

    module InstanceMethods

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
          [app_url.gsub(/\/$/,""), url.gsub(/^\//,"")].join("/") + (params.blank? ? "" : "?#{params}")
        rescue Exception => e
          raise "#{url_key} of #{app_name} seems not configured correctly in #{app_name}'s site_config.yml"
        end
      end

      def authenticate_ip_address
        INTRANET_IP.each do |ip|
          return if ip.contains?(request.remote_ip)
        end
        respond_to do |format|
          format.html{ render :text => "Access Denied!" }
          format.xml{ render :xml => {:info => "Access Denied!"}.to_xml, :status => :forbidden}
        end
      end
    end

    module SingletonMethods
      def ip_limited_access(options = {})
        before_filter(:authenticate_ip_address, options) if Rails.env == "production"
      end
    end
  end
end

