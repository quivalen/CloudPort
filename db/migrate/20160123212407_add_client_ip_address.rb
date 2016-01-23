class AddClientIpAddress < ActiveRecord::Migration
  def up
    execute "ALTER TABLE `builds` ADD COLUMN `client_ip_address` VARCHAR(45) NOT NULL DEFAULT '0.0.0.0' AFTER `cpu_architecture`"
    execute "CREATE INDEX `index_builds_on_client_ip_address` ON `builds` (`client_ip_address`)"
  end

  def down
    execute "ALTER TABLE `builds` DROP COLUMN `client_ip_address`"
  end
end
