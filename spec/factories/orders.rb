FactoryGirl.define do
  factory :order do
    user nil
order_number "MyString"
payment_method "MyString"
failure_reason "MyString"
total_price "9.99"
total_point "9.99"
total_pay "9.99"
created_at "2016-01-18 10:38:27"
cancelled_at "2016-01-18 10:38:27"
paying_at "2016-01-18 10:38:27"
paid_at "2016-01-18 10:38:27"
failed_at "2016-01-18 10:38:27"
repaid_at "2016-01-18 10:38:27"
  end

end
