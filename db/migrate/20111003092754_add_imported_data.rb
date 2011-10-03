class AddImportedData < ActiveRecord::Migration
  def up
    create_table :data_rows do |t|
      t.integer :import_id
      t.string :sk_id, :limit => 22
      t.text :source
      t.string :company_id, :user_id, :limit => 22
      t.timestamps
    end
  end

  def down
    drop_table :data_rows
  end
end
