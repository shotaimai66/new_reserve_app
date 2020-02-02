FactoryBot.define do
  factory :delivery_massage do
    title { "MyString" }
    message { "MyText" }
    delivery_date { "2020-02-02 20:08:34" }
    is_draft { false }
  end
end
