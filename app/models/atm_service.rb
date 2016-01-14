class AtmService
  def self.pay(order_number:, total_pay:)
    last_digit = order_number.chars.last.to_i rescue 9
    return case last_digit
    when (0..6) then { error_code: 0, atm_account: Faker::Number.number(10) }
    else
      { error_code: (rand(9) + 1), msg: Faker::Lorem.sentence(3) }
    end
  end
end
