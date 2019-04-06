class CartController < ApplicationController
  before_action :authenticate_user!, except: [:add_to_cart, :view_order, :clear_cart, :delete_item]
  before_action :set_line_item, only: :delete_item

  def add_to_cart
    @order = current_order
    @order.save if @order.id.nil?
    session[:order_id] = @order.id

# debugger
    # if @order.line_items.pluck(:product_id).uniq.include? line_item_params['product_id'].to_i
    #   line_item = LineItem.find_by(product_id: line_item_params['product_id'].to_i)
    #   line_item.update(quantity: line_item.quantity + line_item_params['quantity'].to_i)
    # else
    #   line_item = LineItem.create(line_item_params)
    # end

    line_item = @order.line_items.find_or_create_by(product_id: line_item_params['product_id'].to_i)
    line_item.quantity.nil? ? line_item.update(quantity: line_item_params['quantity'].to_i) :
                              line_item.update(quantity: line_item.quantity +
                              line_item_params['quantity'].to_i)
    line_item.update(order_id: @order.id)
    line_item.update(line_item_total: (line_item.quantity * line_item.product.price))
    # line_item.save
    redirect_back(fallback_location: root_path)
  end

  def view_order
    @line_items = current_order.line_items
  end

  def clear_cart
    current_order.line_items.delete_all
    redirect_back(fallback_location: root_path)
  end

  def delete_item
    current_order.line_items.find_by(product_id: params[:product_id]).delete
    view_order
    set_cart_count
    render :view_order
  end

  def checkout
    @order = current_order

    if(@order.line_items.length > 0)

      @order.subtotal = 0
      @order.line_items.each do |line_item|
        line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
        @order.order_items[line_item.product_id] = line_item.quantity
        @order.subtotal += line_item.line_item_total
      end

      @order.save
      @order.update(sales_tax: (@order.subtotal * 0.07))
      @order.update(grand_total: (@order.sales_tax + @order.subtotal))
      @order_confirmation = @order
      @order.line_items.destroy_all
      session[:order_id] = nil
      set_cart_count
    end
  end

  private

    def line_item_params
      params.require(:line_item).permit(:product_id, :quantity, :order_id, :line_item_id)
    end

end
