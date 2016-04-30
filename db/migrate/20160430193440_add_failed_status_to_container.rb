class AddFailedStatusToContainer < ActiveRecord::Migration
  def change
    execute "ALTER TABLE containers ADD COLUMN is_failed TINYINT(1) NOT NULL DEFAULT 0 AFTER docker_container_id;"
    execute "ALTER TABLE containers ADD COLUMN failure_message VARCHAR(255) NOT NULL DEFAULT '' AFTER is_failed;"
  end
end
