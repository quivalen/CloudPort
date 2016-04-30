class AddIndexToFailedContainer < ActiveRecord::Migration
  def change
    add_index :containers, :is_failed
  end
end
