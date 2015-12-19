class AddBuildStatus < ActiveRecord::Migration
  def up
    add_column :builds, :status, :boolean, null: false
  end

  def down
    remove_column :builds, :status
  end
end
