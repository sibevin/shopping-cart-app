FactoryGirl.define do
  factory :product do
    sequence(:name) { |n| "Product Name #{n}" }
    sequence(:description) { |n| "Product Description #{n}" }
    unit_price { Faker::Number.number(4) }
  end
end
