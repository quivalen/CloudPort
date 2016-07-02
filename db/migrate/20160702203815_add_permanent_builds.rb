class AddPermanentBuilds < ActiveRecord::Migration
  def change
    execute "ALTER TABLE `builds` ADD COLUMN `is_permanent` TINYINT(1) NOT NULL DEFAULT 0 AFTER `client_ip_address`;"

    add_index :builds, :is_permanent
  end
end
