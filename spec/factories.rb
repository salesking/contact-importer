FactoryGirl.define do
  factory :attachment do
    uploaded_data { file_upload('test1.csv') }
    col_sep ';'
    quote_char '"'
    encoding 'utf-8'
    association :mapping
  end
  
  factory :mapping do
 
  end
  
  #data rwo will be like this ["Test organization", "Test", "male_user", "test_user1@email.com", "Herr", "1980-01-10"]
  factory :mapping_element do
    mapping
    source 0
    target 'organization'
  end
  
  factory :fname_mapping_element, :class => MappingElement do
    mapping
    source '1,2'
    target 'first_name'
    conv_type 'join'
  end
  
  factory :email_mapping_element, :class => MappingElement  do
    mapping
    source 3
    target 'email'
  end
  
  factory :gender_mapping_element, :class => MappingElement do
    mapping
    source 4
    target 'gender'
    conv_type 'enum'
    conv_opts  "{\"male\":\"Herr\",\" female\":\"Frau\"}"
  end
  
  factory :birthday_mapping_element, :class => MappingElement do
    mapping
    source 5
    target 'birthday'
    conv_type 'date'
    conv_opts "{\"date\":\"%Y-%M-%d\"}"
  end
  
  
  
  factory :import do
    association :attachment
  end
 
end
