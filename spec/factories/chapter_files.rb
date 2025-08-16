# frozen_string_literal: true

FactoryBot.define do
  factory :chapter_file do
    product_file
    url { "https://s3.amazonaws.com/gumroad-specs/chapters/chapter.vtt" }
    language { "English" }
    file_name { "chapter" }
    extension { "VTT" }
    file_size { 1024 }
    size { 1024 }
    external_id { SecureRandom.hex(16) }

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
