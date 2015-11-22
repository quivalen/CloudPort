class AddBuildStatus < ActiveRecord::Migration
  def up
    add_column :builds, :status, :boolean, null: false
  end

  def down
    add_column :builds, :status
  end
end
