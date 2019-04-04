class CartController < ApplicationController
  before_action :authenticate_user!, except: [:add_to_cart, :view_controller]

  def add_to_cart
    @order = current_order
    line_item = LineItem.create(product_id: params[:product_id], quantity: params[:quantity])
    @order.save
    session[:order_id] = @order.id
    line_item.update(line_item_total: (line_item.quantity * line_item.product.price))
    redirect_back(fallback_location: root_path)
  end

  def view_order
    @line_items = current_order.line_items
    # @grand_total = @line_items
  end

  def clear_cart
    LineItem.delete_all
    redirect_back(fallback_location: root_path)
  end

  def checkout
    line_items = current_order.line_items

    if(line_items.length > 0)
      current_order.update(user_id: current_user.id, sub_total: 0)
      @order = current_order
        debugger
      line_items.each do |line_item|
        line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
        @order.order_items[line_item.product_id] = line_item.quantity
        @order.subtotal += line_item.line_item_total
      end
      @order.save
      @order.update(sales_tax: (@order.subtotal * 0.08))
      @order.update(grand_total: (@order.sales_tax + @order.subtotal))

      @order.line_items.destroy_all
      session[:order_id] = nil
    end
  end
end
