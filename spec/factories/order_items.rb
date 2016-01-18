FactoryGirl.define do
  factory :order_item do
    order nil
product nil
unit_price "9.99"
count 1
name "MyString"
description "MyText"
  end

end
