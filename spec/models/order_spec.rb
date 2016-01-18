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

  describe ".cancel" do
    let(:order) { build(:order, state: 'shopping') }

    it "should change state to 'cancelled'" do
      order.cancel
      expect(order.state).to eq('cancelled')
    end

    it "should record the cancelled_at" do
      time_now = Time.now
      travel_to(time_now)
      order.cancel
      expect(order.cancelled_at.to_s(:db)).to eq(time_now.to_s(:db))
    end

    it "should do nothing if the order state is not 'shopping'" do
      ['cancelled', 'paying', 'paid', 'failed'].each do |st|
        order = build(:order, state: st)
        order.cancel
        expect(order.state).to eq(st)
        expect(order.cancelled_at).to be_blank
      end
    end
  end
end
