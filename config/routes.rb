Requests::Engine.routes.draw do
  get "/", to: 'request#index'
  get '/pageable', to: 'request#pageable'
  get ':system_id', to: 'request#generate' #, constraints: { system_id: /(\d|^dsp).+/ }
  post '/submit', to: 'request#submit'
  root to: "request#index"
end
