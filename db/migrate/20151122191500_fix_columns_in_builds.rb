class FixColumnsInBuilds < ActiveRecord::Migration
  def change
    change_column :builds, :name,         :string, null: false
    change_column :builds, :build_id,     :string, null: false
    change_column :builds, :ssh_server,   :string, null: false
    change_column :builds, :ssh_username, :string, null: false
    change_column :builds, :ssh_password, :string, null: false
    change_column :builds, :target_host,  :string, null: false
    change_column :builds, :exposed_bind, :string, null: false

    change_column :builds, :exposed_port, :integer, null: false

    remove_column :builds, :target_port
  end
end
