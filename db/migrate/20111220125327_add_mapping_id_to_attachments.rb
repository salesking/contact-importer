class AddMappingIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :mapping_id, :integer
  end
end
