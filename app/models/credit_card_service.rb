class CreditCardService
  def self.pay(order_number:, total_pay:)
    last_digit = order_number.chars.last.to_i rescue 9
    return case last_digit
    when (0..3) then { error_code: 0 }
    when (4..6) then { error_code: 1 }
    else
      { error_code: (rand(8) + 2), msg: Faker::Lorem.sentence(3) }
    end
  end
end
