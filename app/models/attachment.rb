# encoding: utf-8

# Store uploaded files, temporary until the import is created
# 
# If files need to present afterwards should implement persistent s3 storage!!

require 'csv'

class Attachment < ActiveRecord::Base
  FILE_DIR = Rails.root.join('tmp', 'attachments')

  belongs_to :mapping
  has_many :imports, dependent: :destroy

  scope :by_c, lambda { |company_id| where(company_id: company_id) }
  default_scope order('attachments.id desc')

  after_create :store_file
  after_destroy :delete_file

  validates :filename, :disk_filename, presence: true
  validates :col_sep, :quote_char, presence: true

  attr_accessible :col_sep, :quote_char, :uploaded_data
  
  # Any upload file gets passed in as uploaded_data attribute
  # Here its beeing parsed into its bits and pieces so the other attributes can
  # be set (filesize / filename / ..)
  # Sets instance var @uploaded_file, which points to a temp file object and is
  # stored to its final destination after save
  def uploaded_data=(data)
    return if data.nil? #&& data.size > 0
    #set new values
    self.filename = data.original_filename.strip.gsub(/[^\w\d\.\-]+/, '_')
    self.disk_filename = Attachment.disk_filename(filename)
    #check for small files indicated by beeing a StringIO
    @uploaded_file = data
  end

  # full path with filename
  def full_filename
    File.join(path, self.disk_filename)
  end
  
  def rows(size = 0)
    parsed_data[0..(size - 1)]
  end

private

  # When parsing data, we expect our file to be saved as valid utf-8
  def parsed_data
    @parsed_data ||= CSV.read(full_filename, col_sep: col_sep, quote_char: quote_char, encoding: 'UTF-8' )
  end

  # store the uploaded tempfile.
  def store_file
    # TODO 
    # - kick BOM if present
    # - convert to UTF-8 if a different encoding is given
    # - we should check double encoding because the tempfile is always read as utf8
    
    # writes the file binary/raw without taking encodings into account. 
    # If we want to convert incoming files this should be done before
    File.open(full_filename, 'wb') do |f| #w:UTF-8
      f.write @uploaded_file.read
    end
  end

  def delete_file
    File.delete(full_filename)
  end


  def path
    FileUtils.mkdir_p(FILE_DIR) unless File.directory?(FILE_DIR)
    FILE_DIR
  end

  # Returns an ASCII or hashed filename prefixed with the current timestamp
  def self.disk_filename(filename)
    filename = filename.strip.gsub(/[^\w\d\.\-]+/, '_')
    #%L milliseconds 000-999
    df = DateTime.now.strftime("%y%m%d%H%M%S%L") + "_"
    if filename =~ %r{^[a-zA-Z0-9_\.\-]*$}
      df << filename
    else
      df << Digest::MD5.hexdigest(filename)
      # keep the extension if any
      df << $1 if filename =~ %r{(\.[a-zA-Z0-9]+)$}
    end
    df
  end
end
