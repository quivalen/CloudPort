class ReorderDockerContainerId < ActiveRecord::Migration
  def change
     execute "ALTER TABLE `builds` MODIFY COLUMN `docker_container_id` VARCHAR(255) NOT NULL AFTER `build_id`;"
  end
end
