ActionController::Routing::Routes.draw do |map|
  map.resources :mocks
  map.resources :users
  map.resources :comments

  map.home '', :controller => 'home', :actions => 'index'

  map.connect ':mock_path', :controller => 'mocks', :action => 'show',
                            :mock_path => /.*/
end
