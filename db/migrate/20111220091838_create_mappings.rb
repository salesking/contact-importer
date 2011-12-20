class CreateMappings < ActiveRecord::Migration
  def change
    create_table :mappings do |t|
      t.string :company_id, :user_id, :limit => 22

      t.timestamps
    end
  end
end
