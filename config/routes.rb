ActionController::Routing::Routes.draw do |map|
  map.resources :comments, :collection => {:ajax_create => :post}
  map.resources :mocks
  map.resources :mock_lists
  map.resources :projects, :member => {:mock_list_selector => :get}
  map.resource  :session
  map.resources :settings, :collection => {:email => :get}
  map.resources :users

  map.home '', :controller => 'home', :actions => 'index'
end
