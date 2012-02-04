FactoryGirl.define do
  factory :attachment do
    uploaded_data { file_upload('test1.csv') }
    col_sep ';'
    quote_char '"'
    association :mapping, :factory => :mapping
  end
  
  factory :mapping do
 
  end
  
  factory :mapping_element do
    mapping
    source 0
    target 'organization'
  end
  
  factory :email_mapping_element, :class => MappingElement  do
    mapping
    source 2
    target 'email'
  end
  
  factory :gender_mapping_element, :class => MappingElement do
    association :mapping, :factory => :mapping
    source 3
    target 'gender'
    conv_type 'enum'
    conv_opts  "{\"male\":\"Herr\",\" female\":\"Frau\"}"
  end
  
  factory :birthday_mapping_element, :class => MappingElement do
    association :mapping
    source 4
    target 'birthday'
    conv_type 'date'
    conv_opts "{\"date\":\"%Y-%M-%d\"}"
 
  end
  
  factory :import do
    association :attachment
  end
 
end
