require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:time_now) { Time.now.utc }

  describe "when initalization" do
    it "should have a 'shopping' state" do
      order = build(:order)
      expect(order.state).to eq('shopping')
    end

    it "should have a order_number" do
      travel_to(time_now) do
        order = create(:order, created_at: time_now)
        expect(order.order_number).to match(/#{time_now.strftime('%Y%m%d')}\d{6}/)
      end
    end
  end

  describe ".cancel" do
    let(:order) { build(:order, state: 'shopping') }

    it "should change state to 'cancelled'" do
      order.cancel
      expect(order.state).to eq('cancelled')
    end

    it "should record the cancelled_at" do
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

    it "should record the paying_at" do
      travel_to(time_now) do
        order.start_paying(payment_method: payment_method)
        expect(order.paying_at.to_s(:db)).to eq(time_now.to_s(:db))
      end
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
        order_item1 = create(:order_item, order: @order, product: @product)
        order_item2 = create(:order_item, order: @order, product: @product)
        @total_price = @product.unit_price * order_item1.count + @product.unit_price * order_item2.count
      end

      it "should calculate the total_price" do
        @order.start_paying(payment_method: payment_method)
        expect(@order.total_price).to eq(@total_price)
      end

      it "should update the order item's unit_price, name and description" do
        @order.start_paying(payment_method: payment_method)
        expect(@order.order_items.first.name).to eq(@product.name)
        expect(@order.order_items.first.unit_price).to eq(@product.unit_price)
        expect(@order.order_items.first.description).to eq(@product.description)
      end

      it "should calculate total pay" do
        total_point = Faker::Number.number(3).to_i
        @order.start_paying(payment_method: payment_method, total_point: total_point)
        expect(@order.total_pay).to eq(@total_price - total_point)
      end
    end

    it "should record the total_point" do
      total_point = Faker::Number.number(3).to_i
      order.start_paying(payment_method: payment_method, total_point: total_point)
      expect(order.total_point).to eq(total_point)
    end

    describe "record payment method" do
      let(:order) { create(:order, state: 'shopping') }

      it "should record the given payment method if total_pay is not 0" do
        product = create(:product, unit_price: Faker::Number.number(3).to_i + 1)
        create(:order_item, order: order, product: product)
        payment_method = (Order::PAYMENT_METHODS - ['free']).sample
        order.start_paying(payment_method: payment_method)
        expect(order.payment_method).to eq(payment_method)
      end

      it "should change the payment method to 'free' if total_pay is 0" do
        product = create(:product, unit_price: 0)
        create(:order_item, order: order, product: product)
        payment_method = (Order::PAYMENT_METHODS - ['free']).sample
        order.start_paying(payment_method: payment_method)
        expect(order.payment_method).to eq('free')
      end
    end

    describe "handle payment method" do

      before(:example) do
        @product = create(:product, unit_price: Faker::Number.number(3).to_i + 1)
        @order = create(:order, state: 'shopping')
        order_item1 = create(:order_item, order: @order, product: @product)
        order_item2 = create(:order_item, order: @order, product: @product)
        @total_price = @product.unit_price * order_item1.count + @product.unit_price * order_item2.count
      end

      describe "'free' payment method" do
        it "should set expired_at with nil" do
          @order.start_paying(payment_method: 'free')
          expect(@order.expired_at).to be_blank
        end
      end

      describe "'credit_card' payment method" do
        it "should set expired_at with 2 hours" do
          travel_to(time_now) do
            @order.start_paying(payment_method: 'credit_card')
            expect(@order.expired_at.to_s(:db)).to eq(2.hours.since.to_s(:db))
          end
        end

        it "should change state to 'paid' and record paid_at if payment is done" do
          travel_to(time_now) do
            allow(PaymentMethodService).to receive(:run_paying) { { status: :succ, redirect: :credit_card_succ } }
            result = @order.start_paying(payment_method: 'credit_card')
            expect(@order.state).to eq('paid')
            expect(@order.paid_at.to_s(:db)).to eq(time_now.to_s(:db))
            expect(result[:redirect]).to eq(:credit_card_succ)
          end
        end

        it "should keep state with 'paying' if payment is pending" do
          travel_to(time_now) do
            allow(PaymentMethodService).to receive(:run_paying) { { status: :pending, redirect: :credit_card_pending } }
            result = @order.start_paying(payment_method: 'credit_card')
            expect(@order.state).to eq('paying')
            expect(result[:redirect]).to eq(:credit_card_pending)
          end
        end

        it "should change state to 'failed', record failed_at and failure_reason if payment is failed" do
          travel_to(time_now) do
            error_msg = Faker::Lorem.sentence(3)
            allow(PaymentMethodService).to receive(:run_paying) { { status: :failed, redirect: :credit_card_failed, msg: error_msg} }
            result = @order.start_paying(payment_method: 'credit_card')
            expect(@order.state).to eq('failed')
            expect(@order.failed_at.to_s(:db)).to eq(time_now.to_s(:db))
            expect(@order.failure_reason).to eq(error_msg)
            expect(result[:redirect]).to eq(:credit_card_failed)
          end
        end
      end

      describe "'pay_pig' payment method" do
        it "should set expired_at with 1 day" do
          travel_to(time_now) do
            @order.start_paying(payment_method: 'pay_pig')
            expect(@order.expired_at.to_s(:db)).to eq(1.day.since.to_s(:db))
          end
        end

        it "should change state to 'paid' and record paid_at if payment is done" do
          travel_to(time_now) do
            allow(PaymentMethodService).to receive(:run_paying) { { status: :succ, redirect: :pay_pig_succ } }
            result = @order.start_paying(payment_method: 'pay_pig')
            expect(@order.state).to eq('paid')
            expect(@order.paid_at.to_s(:db)).to eq(time_now.to_s(:db))
            expect(result[:redirect]).to eq(:pay_pig_succ)
          end
        end

        it "should keep state with 'paying' if payment is pending" do
          travel_to(time_now) do
            allow(PaymentMethodService).to receive(:run_paying) { { status: :pending, redirect: :pay_pig_pending } }
            result = @order.start_paying(payment_method: 'pay_pig')
            expect(@order.state).to eq('paying')
            expect(result[:redirect]).to eq(:pay_pig_pending)
          end
        end

        it "should change state to 'failed', record failed_at and failure_reason if payment is failed" do
          travel_to(time_now) do
            error_msg = Faker::Lorem.sentence(3)
            allow(PaymentMethodService).to receive(:run_paying) { { status: :failed, redirect: :pay_pig_failed, msg: error_msg} }
            result = @order.start_paying(payment_method: 'pay_pig')
            expect(@order.state).to eq('failed')
            expect(@order.failed_at.to_s(:db)).to eq(time_now.to_s(:db))
            expect(@order.failure_reason).to eq(error_msg)
            expect(result[:redirect]).to eq(:pay_pig_failed)
          end
        end
      end

      describe "'atm' payment method" do
        it "should set expired_at with 7 days" do
          travel_to(time_now) do
            @order.start_paying(payment_method: 'atm')
            expect(@order.expired_at.to_s(:db)).to eq(7.days.since.to_s(:db))
          end
        end

        it "should keep state with 'paying' if payment is pending" do
          travel_to(time_now) do
            atm_account = RandomToken.gen(10, s: :n)
            allow(PaymentMethodService).to receive(:run_paying) { { status: :pending, redirect: :atm_pending, atm_account: atm_account } }
            result = @order.start_paying(payment_method: 'atm')
            expect(@order.state).to eq('paying')
            expect(result[:redirect]).to eq(:atm_pending)
            expect(result[:atm_account]).to eq(atm_account)
          end
        end

        it "should change state to 'failed', record failed_at and failure_reason if payment is failed" do
          travel_to(time_now) do
            error_msg = Faker::Lorem.sentence(3)
            allow(PaymentMethodService).to receive(:run_paying) { { status: :failed, redirect: :atm_failed, msg: error_msg} }
            result = @order.start_paying(payment_method: 'atm')
            expect(@order.state).to eq('failed')
            expect(@order.failed_at.to_s(:db)).to eq(time_now.to_s(:db))
            expect(@order.failure_reason).to eq(error_msg)
            expect(result[:redirect]).to eq(:atm_failed)
          end
        end
      end
    end

  end

end
