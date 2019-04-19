Rails.application.routes.draw do
  root 'storefront#all_items'
  post 'add_to_cart' => 'cart#add_to_cart'
  get 'view_order' => 'cart#view_order'
  get 'checkout' => 'cart#checkout'
  get 'index' => 'storefront#all_items'
  get 'categorical' => 'storefront#items_by_category'
  get 'branding' => 'storefront#items_by_brand'
  get 'clear_cart' => 'cart#clear_cart'
  post 'delete_item' => 'cart#delete_item'
  post 'order_complete' => 'cart#order_complete'
  devise_for :users
  resources :products
  resources :charges
end
