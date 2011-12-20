FactoryGirl.define do
  factory :attachment do
    uploaded_data { file_upload('test1.csv') }
    col_sep ';'
    quote_char '"'
    association :mapping
  end
  
  factory :mapping do
  end
  
  factory :mapping_element do
    association :mapping
    source 0
    target 'organization'
  end
  
  factory :import do
    association :attachment
  end
end
