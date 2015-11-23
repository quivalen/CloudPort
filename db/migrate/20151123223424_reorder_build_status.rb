class ReorderBuildStatus < ActiveRecord::Migration
  def change
    execute "ALTER TABLE `builds` MODIFY COLUMN `status` TINYINT(1) NOT NULL AFTER `exposed_port`;"
  end
end
