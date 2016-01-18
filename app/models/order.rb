class Order < ActiveRecord::Base
  STATES = ['shopping', 'cancelled', 'paying', 'paid', 'failed']
  PAYMENT_METHODS = ['free', 'credit_card', 'pay_pig', 'atm']

  include Uidable
  uidable uid_name: :order_number

  belongs_to :user
  has_many :order_items

  def cancel
    if self.state == 'shopping'
      self.cancelled_at = Time.now
      self.state = 'cancelled'
    end
  end

  def pay
    if self.state == 'paying'
      self.paid_at = Time.now
      self.state = 'paid'
    end
  end

  def expire
    if self.state == 'paying' && self.expired_at.present? && self.expired_at <= Time.now
      self.failure_reason = 'expired'
      self.failed_at = Time.now
      self.state = 'failed'
    end
  end

  def start_paying(payment_method:, total_point: 0)
    if self.state == 'shopping'
      self.payment_method = payment_method
      self.paying_at = Time.now
      self.state = 'paying'
      self.total_point = total_point
      update_order_items
      calculate_total_price
      self.total_pay = self.total_price - self.total_point
      if self.total_pay <= 0
        self.payment_method = 'free'
      end
    end
  end

  private

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

  def gen_order_number
    self.created_at = Time.now if self.created_at.blank?
    "#{self.created_at.strftime('%Y%m%d')}#{RandomToken.gen(6, s: :n)}"
  end
end
