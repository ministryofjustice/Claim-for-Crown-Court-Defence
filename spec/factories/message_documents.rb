FactoryBot.define do
  factory :message_document do
    id { 1 }
    message_id { 1 }
    created_at { "2024-12-03 14:20:22" }
    updated_at { "2024-12-03 14:20:22" }
    external_user_id { 1 }
    uuid { "MyString" }
    form_id { "MyString" }
    creator_id { 1 }
    verified_file_size { 1 }
    file_path { "MyString" }
    verified { false }
  end
end
