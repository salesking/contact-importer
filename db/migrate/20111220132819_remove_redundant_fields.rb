class RemoveRedundantFields < ActiveRecord::Migration
  def up
    remove_column :imports, :kind
    remove_column :imports, :name
    remove_column :imports, :col_sep
    remove_column :imports, :quote_char
    remove_column :imports, :started_at
    remove_column :imports, :finished_at
    remove_column :mapping_elements, :import_id
    remove_column :mapping_elements, :company_id
    remove_column :mapping_elements, :user_id
  end

  def down
    add_column :mapping_elements, :user_id, :string,       :limit => 22
    add_column :mapping_elements, :company_id, :string,    :limit => 22
    add_column :mapping_elements, :import_id, :integer
    add_column :imports, :finished_at, :datetime
    add_column :imports, :started_at, :datetime
    add_column :imports, :quote_char, :string,    :limit => 1
    add_column :imports, :col_sep, :string,       :limit => 1
    add_column :imports, :name, :string,          :limit => 60
    add_column :imports, :kind, :string,          :limit => 30
  end
end
