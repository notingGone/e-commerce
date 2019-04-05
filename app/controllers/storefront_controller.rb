class StorefrontController < ApplicationController
  before_action :set_line_item

  def all_items
    @products = Product.all
  end

  def items_by_category
    @products = Product.where(category_id: params[:category_id])
    @category = Category.find(params[:category_id])
    # @products = Product.all.order(:category_id)
  end

  def items_by_brand
    # @products = Product.all.order(:brand)
    @products = Product.where(brand: params[:brand])
    @brand = params[:brand]
  end
end
