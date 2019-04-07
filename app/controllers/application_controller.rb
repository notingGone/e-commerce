class ApplicationController < ActionController::Base
  # before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :categories, :brands
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_cart_count
  helper_method :current_order

  def categories
    @categories = Category.order(:name)
  end

  def brands
    @brands = Product.pluck(:brand).sort.uniq
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role, :name])
  end

  def current_order
    if session[:order_id]
      Order.find(session[:order_id])
    else
      user_signed_in? ? Order.create(user_id: current_user.id) : Order.new
    end
  end

  def set_cart_count
    @cart_count = current_order.line_items.pluck(:quantity).sum or 0
  end

  def set_line_item
    @line_item = LineItem.new
  end
end
