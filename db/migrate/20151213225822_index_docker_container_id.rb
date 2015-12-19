class IndexDockerContainerId < ActiveRecord::Migration
  def change
    add_index :builds, :docker_container_id, unique: true
  end
end
