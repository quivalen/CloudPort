class FixConnectionDefaults < ActiveRecord::Migration
  def change
    execute "ALTER TABLE connections MODIFY COLUMN is_connected TINYINT(1) NOT NULL DEFAULT 1"
  end
end
