class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.integer :build_id, null: false, index: true, uniq: true
      t.string  :docker_container_id, null: false, index: true, uniq: true
      t.timestamps null: false
    end

    add_foreign_key :containers, :builds

    execute "INSERT INTO containers (build_id, docker_container_id, created_at, updated_at) \
      SELECT id, docker_container_id, created_at, updated_at FROM builds"

    execute "ALTER TABLE builds DROP COLUMN docker_container_id"
  end
end
