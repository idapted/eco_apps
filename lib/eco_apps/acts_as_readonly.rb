module Idapted
  module ActsAsReadonly
    def self.included(base)
      base.extend(ClassMethods)
    end
 
    module ClassMethods
      def acts_as_readonly(name, options = {})
        cattr_accessor :app_name
        self.app_name = name

        unless Rails.env == "test"
          begin
            config = YAML.load(options[:database]||CoreService.app(name).database)
            connection = (config[Rails.env] || config["production"] || config)
            establish_connection connection  #activate readonly connection
            
            db_name = self.connection.current_database
            prefix = table_name.include?(db_name) ? "" : db_name + "."
            set_table_name(prefix + (options[:table_name]||table_name).to_s)
          rescue Exception => e
            raise e.message 
          end
        else
          generate_table(self.table_name, options)
        end

        unless options[:readonly] == false or Rails.env == "test"
          include Idapted::ActsAsReadonly::InstanceMethods
          extend Idapted::ActsAsReadonly::SingletonMethods
        end
      end
      alias_method :acts_as_remote, :acts_as_readonly

      def full_table_name
        self.connection.current_database + "." + self.table_name
      end

      private
      def generate_table(table_name, options = {})
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
 
