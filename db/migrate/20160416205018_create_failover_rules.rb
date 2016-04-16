class CreateFailoverRules < ActiveRecord::Migration
  def change
    create_table :failover_rules do |t|
      t.integer :container_id,  limit: 4,       null: false
      t.string  :remote,        limit: 255,     null: false

      t.datetime :created_at, null: false
    end

    add_index :failover_rules, :container_id, unique: false
    add_index :failover_rules, :remote,       unique: true

    add_foreign_key :failover_rules, :containers, on_delete: :cascade
  end
end
