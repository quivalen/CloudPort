class AddFailoverRuleUpdatedAt < ActiveRecord::Migration
  def change
    execute "ALTER TABLE `failover_rules` ADD COLUMN `updated_at` DATETIME NOT NULL AFTER `remote`"
  end
end
