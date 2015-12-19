class AddDockerContainerId < ActiveRecord::Migration
  def change
    add_column :builds, :docker_container_id, :string
  end
end
