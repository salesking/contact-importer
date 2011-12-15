class AddColSepAndQuoteCharToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :col_sep, :string, :limit => 1
    add_column :attachments, :quote_char, :string, :limit => 1
  end
end
