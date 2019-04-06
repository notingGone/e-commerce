class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :order, optional: true
  validates :quantity, presence: true
  validates :quantity, numericality:
    { less_than_or_equal_to: proc { |m| m.product.quantity },
      greater_than: 0 }
end
