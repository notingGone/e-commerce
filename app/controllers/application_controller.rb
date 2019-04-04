class ApplicationController < ActionController::Base
  # before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :categories, :brands
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_order

  def categories
    @categories = Category.order(:name)
  end

  def brands
    @brands = Product.pluck(:brand).sort.uniq
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role, name])
  end

  def current_order
    debugger
    if session[:order_id]
      return Order.find(session[:order_id])
    else
      return Order.new
    end
  end
end
