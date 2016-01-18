require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "when initalization" do
    it "should have a 'shopping' state" do
      order = build(:order)
      expect(order.state).to eq('shopping')
    end

    it "should have a order_number" do
      time_now = Time.now
      travel_to(time_now)
      order = create(:order, created_at: time_now)
      expect(order.order_number).to match(/#{time_now.strftime('%Y%m%d')}\d{6}/)
    end
  end
end
