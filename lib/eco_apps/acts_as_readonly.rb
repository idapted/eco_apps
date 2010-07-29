module Idapted
  module ActsAsReadonly
    def self.included(base)
      base.extend(ClassMethods)
    end
 
    module ClassMethods
      def acts_as_readonly(name, options = {})
        cattr_accessor :app_name, :rails_origin_table_name
        self.app_name = name

        unless Rails.env == "test"
          config = YAML.load(options[:database]||CoreService.app(name).database)
          connection = (config[Rails.env] || config["production"] || config)
          establish_connection connection  #activate readonly connection
            
          db_name = self.connection.current_database
          prefix = table_name.include?(db_name) ? "" : db_name + "."
          tbl = (options[:table_name]||table_name).to_s

          self.rails_origin_table_name = tbl
          set_table_name(prefix + tbl)
        else
          generate_table(self.table_name)
        end

        unless options[:readonly] == false or Rails.env == "test"
          include Idapted::ActsAsReadonly::InstanceMethods
          extend Idapted::ActsAsReadonly::SingletonMethods
        end
      end
      alias_method :acts_as_remote, :acts_as_readonly

      private
      def generate_table(table_name)
        begin
          self.connection.drop_table(self.table_name) if self.connection.table_exists?(self.table_name)
          self.connection.create_table(self.table_name, :force => true){|f|
            if (config = APP_CONFIG["readonly_for_test"].try("[]", table_name)).present?
              config.each{|key, value|
                f.send(key, *(value.is_a?(Array) ? value.join(",") : value.gsub(" ","").split(",")))
              }
            end
            f.timestamps
          }
        rescue Exception => e
          puts "#{e.message} error occured in #{table_name}"
        end
      end
    end
 
    module SingletonMethods
      def delete_all(conditions = nil)
        raise ActiveRecord::ReadOnlyRecord
      end

      def table_exists?
        connection.table_exists?(self.rails_origin_table_name)
      end
    end
 
    module InstanceMethods
      def readonly?
        true
      end
 
      def destroy
        raise ActiveRecord::ReadOnlyRecord
      end
    end
  end
end
 
