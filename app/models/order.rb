class Order < ActiveRecord::Base
  STATES = ['shopping', 'cancelled', 'paying', 'paid', 'failed']
  PAYMENT_METHODS = ['free', 'credit_card', 'pay_pig', 'atm']

  include Uidable
  uidable uid_name: :order_number

  belongs_to :user

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

  def start_paying(payment_method:)
    if self.state == 'shopping'
      self.payment_method = payment_method
      self.paying_at = Time.now
      self.state = 'paying'
    end
  end

  private

  def gen_order_number
    "#{self.created_at.strftime('%Y%m%d')}#{RandomToken.gen(6, s: :n)}"
  end
end
