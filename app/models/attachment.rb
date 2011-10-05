# Store uploaded files, temporary until the import is created
# 
# If files need to present afterwards should implement persistent s3 storage!!
class Attachment < ActiveRecord::Base

  FILE_DIR = Rails.root.join( 'tmp', 'attachments')
  ##############################################################################
  # Associations
  ##############################################################################
  belongs_to :import
  ##############################################################################
  # Callbacks
  ##############################################################################
  after_create :store_file
  after_destroy :delete_file
  ##############################################################################
  # Validations
  ##############################################################################
  validates :filename, :disk_filename, :presence=>true
  ##############################################################################
  # Behavior
  ##############################################################################
  attr_accessible :uploaded_data

  
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

private

  def store_file
    File.open(full_filename, 'wb') do |f|
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
