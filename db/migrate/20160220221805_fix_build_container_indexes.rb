class FixBuildContainerIndexes < ActiveRecord::Migration
  def change
    remove_foreign_key :connections, :builds

    execute "ALTER TABLE builds CHANGE COLUMN build_id ptu_build_id varchar(6) NOT NULL AFTER id"
    execute "ALTER TABLE connections DROP COLUMN build_id"
    execute "ALTER TABLE connections ADD COLUMN container_id INT(11) NOT NULL AFTER id"

    add_index :connections, :container_id
    ## add_foreign_key "connections", "containers"

    add_index :builds, :ptu_build_id, unique: true

    remove_foreign_key :containers, :builds

    remove_index :containers, :build_id
    remove_index :containers, :docker_container_id

    add_index :containers, :build_id, unique: true
    add_index :containers, :docker_container_id, unique: true

    execute "DROP INDEX index_builds_on_build_id ON builds"
  end
end
