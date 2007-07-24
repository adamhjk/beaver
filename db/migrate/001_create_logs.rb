class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.column :name, :text, :null => false
      t.column :shasum, :string, :limit => 42, :null => false
      t.column :source, :text, :null => false
      t.column :status, :string, :null => false
    end
  end

  def self.down
    drop_table :logs
  end
end
