class RenameRemoteToSourceIpAddress < ActiveRecord::Migration
  def change
    execute "ALTER TABLE failover_rules CHANGE remote source_ip_address VARCHAR(255) NOT NULL"

    add_index :failover_rules, :source_ip_address, unique: true
  end
end
