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
      travel_to(time_now) do
        order.cancel
        expect(order.cancelled_at.to_s(:db)).to eq(time_now.to_s(:db))
      end
    end

    it "should do nothing if the order state is not 'shopping'" do
      (Order::STATES - ['shopping']).each do |st|
        order = build(:order, state: st)
        order.cancel
        expect(order.state).to eq(st)
        expect(order.cancelled_at).to be_blank
      end
    end
  end

  describe ".pay" do
    let(:order) { build(:order, state: 'paying') }

    it "should change state to 'paid'" do
      order.pay
      expect(order.state).to eq('paid')
    end

    it "should record the paid_at" do
      time_now = Time.now
      travel_to(time_now) do
        order.pay
        expect(order.paid_at.to_s(:db)).to eq(time_now.to_s(:db))
      end
    end

    it "should do nothing if the order state is not 'paying'" do
      (Order::STATES - ['paying']).each do |st|
        order = build(:order, state: st)
        order.pay
        expect(order.state).to eq(st)
        expect(order.paid_at).to be_blank
      end
    end
  end

  describe ".expire" do
    let(:order) { build(:order, state: 'paying', expired_at: 1.hour.ago) }

    it "should change state to 'failed' if the order is expired" do
      order.expire
      expect(order.state).to eq('failed')
    end

    it "should record the failed_at" do
      time_now = Time.now
      travel_to(time_now) do
        order.expire
        expect(order.failed_at.to_s(:db)).to eq(time_now.to_s(:db))
      end
    end

    it "should record the failure reason with 'expired'" do
      order.expire
      expect(order.failure_reason).to eq('expired')
    end

    it "should do nothing if the order state is not 'paying'" do
      (Order::STATES - ['paying']).each do |st|
        order = build(:order, state: st, expired_at: 1.hour.ago)
        order.expire
        expect(order.state).to eq(st)
        expect(order.failed_at).to be_blank
      end
    end

    it "should do nothing if the order is not expired" do
      order = build(:order, state: 'paying', expired_at: 1.hour.since)
      order.expire
      expect(order.state).to eq('paying')
      expect(order.failed_at).to be_blank
    end
  end

  describe ".start_paying" do
    let(:order) { build(:order, state: 'shopping') }
    let(:payment_method) { Order::PAYMENT_METHODS.sample }

    it "should change state to 'paying'" do
      order.start_paying(payment_method: payment_method)
      expect(order.state).to eq('paying')
    end

    it "should record the paying_at" do
      time_now = Time.now
      travel_to(time_now) do
        order.start_paying(payment_method: payment_method)
        expect(order.paying_at.to_s(:db)).to eq(time_now.to_s(:db))
      end
    end

    it "should record the given payment method" do
      order.start_paying(payment_method: payment_method)
      expect(order.payment_method).to eq(payment_method)
    end

    it "should do nothing if the order state is not 'shopping'" do
      (Order::STATES - ['shopping']).each do |st|
        order = build(:order, state: st)
        order.start_paying(payment_method: payment_method)
        expect(order.state).to eq(st)
        expect(order.paying_at).to be_blank
      end
    end

    describe "handle order items" do
      before(:example) do
        @product = create(:product)
        @order = create(:order, state: 'shopping')
        @order_item1 = create(:order_item, order: @order, product: @product, count: rand(10) + 1)
        @order_item2 = create(:order_item, order: @order, product: @product, count: rand(10) + 1)
      end

      it "should calculate the total_price" do
        @order.start_paying(payment_method: payment_method)
        expect(@order.total_price).to eq(@order_item1.unit_price * @order_item1.count + @order_item2.unit_price * @order_item2.count)
      end

      it "should update the order item's unit_price, name and description" do
        @order.start_paying(payment_method: payment_method)
        expect(@order.order_items.first.name).to eq(@product.name)
        expect(@order.order_items.first.unit_price).to eq(@product.unit_price)
        expect(@order.order_items.first.description).to eq(@product.description)
      end
    end

  end

end
