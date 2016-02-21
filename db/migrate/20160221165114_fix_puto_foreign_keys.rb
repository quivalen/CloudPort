class FixPutoForeignKeys < ActiveRecord::Migration
  def change
    remove_foreign_key "containers",  "builds"
    remove_foreign_key "connections", "containers"

    add_foreign_key "containers",  "builds",     on_delete: :cascade
    add_foreign_key "connections", "containers", on_delete: :cascade
  end
end
