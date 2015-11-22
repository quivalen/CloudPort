class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.string :name
      t.string :build_id
      t.string :ssh_server
      t.string :ssh_username
      t.string :ssh_password
      t.string :target_host
      t.string :target_port
      t.string :exposed_bind
      t.integer :exposed_port

      t.timestamps null: false
    end
  end
end
