class AddMappingIdToMappingElements < ActiveRecord::Migration
  def change
    add_column :mapping_elements, :mapping_id, :integer
  end
end
