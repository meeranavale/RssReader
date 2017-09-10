Rails.application.routes.draw do
  root 'feeds#index'

  resources :feeds do
	  collection do
	    get :post
	  end
	end
end
