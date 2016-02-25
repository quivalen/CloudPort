class AddIsForwardedToConnections < ActiveRecord::Migration
  def change
    execute "ALTER TABLE `connections` ADD COLUMN `is_forwarded` TINYINT(1) NOT NULL DEFAULT 0 AFTER `remote`"

    add_index :connections, :remote, unique: true
    add_index :connections, :is_forwarded
  end
end
