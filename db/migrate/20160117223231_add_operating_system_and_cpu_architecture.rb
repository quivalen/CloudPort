class AddOperatingSystemAndCpuArchitecture < ActiveRecord::Migration
  def change
    execute "ALTER TABLE `builds` ADD COLUMN `operating_system` VARCHAR(10) NOT NULL DEFAULT 'windows' AFTER `exposed_port`"
    execute "ALTER TABLE `builds` ADD COLUMN `cpu_architecture` VARCHAR(10) NOT NULL DEFAULT 'amd64' AFTER `operating_system`"

    execute "CREATE INDEX `index_builds_on_operating_system` ON `builds` (`operating_system`)"
    execute "CREATE INDEX `index_builds_on_cpu_architecture` ON `builds` (`cpu_architecture`)"
  end
end
