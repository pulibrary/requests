Requests::Engine.routes.draw do
  get "/", to: 'request#index'
  get '/pageable', to: 'request#pageable'
  get ':system_id', to: 'request#generate' #, constraints: { system_id: /(\d|^dsp).+/ }
  get '/borrow_direct', to: 'request#bd'
  post '/barcode_auth', to: 'request#barcode_auth'
  post '/recall_pickups', to: 'request#recall_pickups'
  post '/submit', to: 'request#submit'
  root to: "request#index"
end
