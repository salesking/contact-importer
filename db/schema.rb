# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111220125327) do

  create_table "attachments", :force => true do |t|
    t.string   "filename",      :limit => 100
    t.string   "disk_filename"
    t.string   "company_id",    :limit => 22
    t.string   "user_id",       :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "col_sep",       :limit => 1
    t.string   "quote_char",    :limit => 1
    t.integer  "mapping_id"
  end

  create_table "data_rows", :force => true do |t|
    t.integer  "import_id"
    t.string   "sk_id",      :limit => 22
    t.text     "source"
    t.text     "log"
    t.string   "company_id", :limit => 22
    t.string   "user_id",    :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imports", :force => true do |t|
    t.string   "name",          :limit => 60
    t.string   "kind",          :limit => 30
    t.string   "col_sep",       :limit => 1
    t.string   "quote_char",    :limit => 1
    t.integer  "attachment_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "company_id",    :limit => 22
    t.string   "user_id",       :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mapping_elements", :force => true do |t|
    t.string   "target",     :limit => 100
    t.string   "conv_type",  :limit => 100
    t.string   "conv_opts"
    t.string   "source"
    t.integer  "import_id"
    t.string   "company_id", :limit => 22
    t.string   "user_id",    :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mapping_id"
  end

  create_table "mappings", :force => true do |t|
    t.string   "company_id", :limit => 22
    t.string   "user_id",    :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
