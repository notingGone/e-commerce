class CartController < ApplicationController
  before_action :authenticate_user!, except: [:add_to_cart, :view_order]

  def add_to_cart
    @order = current_order
    # line_item = LineItem.create(product_id: params[:product_id], quantity: params[:quantity])
    @order.save
    line_item = LineItem.create(line_item_params)
    # line_item = LineItem.find(params[:line_item_id])
    # line_item.update(line_item_params)
    session[:order_id] = @order.id
    line_item.update(line_item_total: (line_item.quantity * line_item.product.price))
    line_item.update(order_id: @order.id)
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

  private

    def line_item_params
      # debugger
      params.require(:line_item).permit(:product_id, :quantity, :order_id)
    end

end
