class Payment < ActiveRecord::Base
  belongs_to :user

  def credits
    Payment.credits_by_amount(amount)
  end

  def self.credits_by_amount(amount)
    Payment.discounted_credits(amount).nil? ? (amount / Tournament.current.cost_pence * 100).to_i : Payment.discounted_credits(amount)
  end

  def self.discounted_credits(amount)
    discounted_amount = {
      0.99 => 3,
      10.0 => 50,
      15.0 => 100
    }[amount.abs.to_f]
    (amount > 0 || discounted_amount.nil? ? discounted_amount : -discounted_amount)
  end
end
