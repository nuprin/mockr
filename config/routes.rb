ActionController::Routing::Routes.draw do |map|
  map.resources :mocks
  map.resource  :session
  map.resources :users
  map.resources :comments, :collection => {:ajax_create => :post}

  map.home '', :controller => 'home', :actions => 'index'

  map.connect ':mock_path', :controller => 'mocks', :action => 'show',
                            :mock_path => /.*/
end
