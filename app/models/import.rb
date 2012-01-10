class Import < ActiveRecord::Base
  include UserReference

  has_many :data_rows, dependent: :destroy
  belongs_to :attachment

  default_scope order('imports.id desc')
  
  validates :attachment, presence: true
  
  after_save :populate_data_rows
  
  def title
    title = I18n.t('imports.title_success', count: data_rows.success.count)
    if (failed = data_rows.failed.count) > 0
      [title, I18n.t('imports.title_failed', count: failed)].to_sentence
    else
      title
    end
  end
  
  def preview(size = 3)
    mapping_elements = attachment.mapping.mapping_elements
    [mapping_elements.collect(&:target)] + attachment.rows[1..size].collect do |row|
      attachment.mapping.mapping_elements.collect do |mapping_element|
        mapping_element.convert(row)
      end
    end
  end

  # An import is successful if no rows failed
  def success?
    data_rows.failed.count == 0
  end
  
  private
  
  def populate_data_rows
    attachment.rows[1..-1].each do |row|
      self.data_rows.create!(data: row)
    end
  end
end