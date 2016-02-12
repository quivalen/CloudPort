class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :build_id, null: false, index: true
      t.string :remote, null: false

      t.datetime :connected_at, null: false
      t.datetime :disconnected_at, null: false
    end

    add_foreign_key :connections, :builds
  end
end
