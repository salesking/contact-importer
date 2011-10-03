class CreateImports < ActiveRecord::Migration
  def up
    create_table :imports do |t|
      t.string :name, :limit => 60
      t.string :kind, :limit => 30
      t.string :col_sep,:quote_char, :limit => 1
      t.integer :attachment_id
      t.datetime :started_at, :finished_at
      t.string :company_id, :user_id, :limit => 22
      t.timestamps
    end

    create_table :attachments do |t|
      t.string :filename, :limit => 100
      t.string :disk_filename
      t.string :company_id, :user_id, :limit => 22
      t.timestamps
    end

    create_table :mappings do |t|
      t.string :target, :limit => 100
      t.string :conv_type, :limit => 100
      t.string :conv_opts
      t.string :source
      t.integer :import_id
      t.string :company_id, :user_id, :limit => 22
      t.timestamps
    end
  end

  def down
    drop_table :imports
    drop_table :attachments
    drop_table :mappings
  end
end
