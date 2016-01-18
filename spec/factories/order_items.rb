FactoryGirl.define do
  factory :order_item do
    count { rand(10) + 1 }
  end
end
