class RenameMappingToMappingElement < ActiveRecord::Migration
  def change
    rename_table :mappings, :mapping_elements
  end
end