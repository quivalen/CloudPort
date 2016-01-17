class DryBuildsForCommonSense < ActiveRecord::Migration
  def change
    execute "UPDATE `builds` SET `build_id` = SUBSTRING(`build_id`, 1, 6)"

    execute "ALTER TABLE `builds` MODIFY COLUMN `build_id`             VARCHAR(6) NOT NULL"
    execute "ALTER TABLE `builds` MODIFY COLUMN `docker_container_id`  VARCHAR(64) NOT NULL"

    execute "ALTER TABLE `builds` CHANGE COLUMN `ssh_server` `ssh_server_address` VARCHAR(255) NOT NULL"
    execute "ALTER TABLE `builds` ADD COLUMN `ssh_server_port` INT(11) NOT NULL AFTER `ssh_server_address`"

    execute "ALTER TABLE `builds` CHANGE COLUMN `target_host` `target_address` VARCHAR(255) NOT NULL"
    execute "ALTER TABLE `builds` ADD COLUMN `target_port` INT(11) NOT NULL AFTER `target_address`"
  end
end
