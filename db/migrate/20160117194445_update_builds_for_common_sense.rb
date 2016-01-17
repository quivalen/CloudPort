class UpdateBuildsForCommonSense < ActiveRecord::Migration
  def change
    execute "UPDATE `builds` SET `ssh_server_port`    = SUBSTRING_INDEX(`ssh_server_address`, ':', -1)"
    execute "UPDATE `builds` SET `ssh_server_address` = SUBSTRING_INDEX(`ssh_server_address`, ':', 1)"

    execute "UPDATE `builds` SET `target_port`    = SUBSTRING_INDEX(`target_address`, ':', -1)"
    execute "UPDATE `builds` SET `target_address` = SUBSTRING_INDEX(`target_address`, ':', 1)"
  end
end
