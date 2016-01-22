class Order < ActiveRecord::Base
  PAYMENT_METHODS = ['free', 'credit_card', 'pay_pig', 'atm']

  include Uidable
  uidable uid_name: :order_number

  belongs_to :user
  has_many :order_items

  include AASM
  aasm column: :state, whiny_transitions: false do
    state :shopping, initial: true
    state :cancelled
    state :paying
    state :paid
    state :failed

    event :cancel do
      transitions from: :shopping, to: :cancelled do
        after do |params|
          self.cancelled_at = Time.now
        end
      end
    end

    event :pay do
      transitions from: :paying, to: :paid do
        after do |params|
          self.paid_at = Time.now
        end
      end
    end

    event :fail do
      transitions from: :paying, to: :failed do
        after do |params|
          handle_failure(params[:msg])
        end
      end
    end

    event :go_paying do
      transitions from: :shopping, to: :paying do
        after do |params|
          self.paying_at = Time.now
          self.total_point = params[:total_point]
          update_order_items
          calculate_total_price
          self.total_pay = self.total_price - self.total_point
          handle_payment_method(params[:payment_method])
          pms = PaymentMethodService.gen(self.payment_method)
          self.expired_at = pms.get_expiration
          run_payment_method_service
        end
      end
    end
  end

  def expire
    self.fail(msg: 'expired') if is_expired?
  end

  def start_paying(payment_method:, total_point: 0)
    if self.go_paying(payment_method: payment_method, total_point: total_point)
      run_payment_method_service
    end
  end

  def add_item(product:, count: 1)
    if is_in_shopping?
      if oi = self.order_items.where(product: product).take
        oi.update_attributes(count: oi.count + count)
      else
        self.order_items.create(product: product, count: count)
      end
    end
  end

  def change_item(order_item:, count:)
    if is_in_shopping?
      if oi = self.order_items.where(id: order_item.id).take
        if count < 1
          oi.destroy
        else
          oi.update_attributes(count: count)
        end
      end
    end
  end

  def delete_item(order_item:)
    if is_in_shopping?
      if oi = self.order_items.where(id: order_item.id).take
        oi.destroy
      end
    end
  end

  private

  def is_expired?
    self.expired_at.present? && self.expired_at <= Time.now
  end

  def is_in_shopping?
    (self.state == 'shopping')
  end

  def handle_failure(msg)
    self.failure_reason = msg
    self.failed_at = Time.now
  end

  def calculate_total_price
    total = 0
    self.order_items.each do |oi|
      total = total + oi.unit_price * oi.count
    end
    self.total_price = total
  end

  def update_order_items
    self.order_items.each do |oi|
      oi.update_attributes(
        unit_price: oi.product.unit_price,
        name: oi.product.name,
        description: oi.product.description,
      )
    end
  end

  def handle_payment_method(given_payment_method)
    self.payment_method = given_payment_method
    if self.total_pay <= 0
      self.payment_method = 'free'
    end
  end

  def run_payment_method_service
    result = PaymentMethodService.run_paying(self.payment_method, self.order_number, self.total_pay)
    if result[:status] == :succ
      self.pay
    elsif result[:status] == :failed
      self.fail(msg: result[:msg])
    else
      self.state = 'paying'
    end
    return result
  end

  def gen_order_number
    self.created_at = Time.now if self.created_at.blank?
    "#{self.created_at.strftime('%Y%m%d')}#{RandomToken.gen(6, s: :n)}"
  end
end
