class App < ActiveRecord::Base
  unless self.table_exists?
    self.connection.create_table :apps do |t|
      t.string :name, :url
      t.text :database, :api
    end
  end
end