FactoryGirl.define do
  factory :attachment do
    uploaded_data { file_upload('test1.csv') }
    col_sep ';'
    quote_char '"'
  end
end
