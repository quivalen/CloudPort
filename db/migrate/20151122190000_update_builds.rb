class UpdateBuilds < ActiveRecord::Migration
  def change
    change_column :builds, :exposed_port, :integer, null: false

    add_index :builds, :build_id, unique: true
  end
end
