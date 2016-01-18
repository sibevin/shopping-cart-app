require 'rails_helper'

RSpec.describe PaymentMethodService::CreditCard, type: :model do
  let(:pms) { PaymentMethodService::CreditCard.new }

  describe "#get_expiration" do
    it "should return 2 hours expiration" do
      time_now = Time.now
      travel_to(time_now) do
        expect(pms.get_expiration.to_s(:db)).to eq(2.hours.since.to_s(:db))
      end
    end
  end

  xdescribe "#run_paying" do
  end
end
