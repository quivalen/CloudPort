class FixForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "containers",  "builds"
    add_foreign_key "connections", "containers"
  end
end
