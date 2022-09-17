require './models/coin'
get '/' do
    coins = run_sql("SELECT * FROM coins")
    # for i in coins
    #     puts i
    # end

    url = URI("https://api.livecoinwatch.com/coins/single")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    
    request = Net::HTTP::Post.new(url)
    request["content-type"] = "application/json"
    request["x-api-key"] = ENV['COIN_API']
    request.body = JSON.dump({
      "currency": "USD",
      "code": "ETH",
      "meta": true
    }) 
    response = https.request(request)
    puts response.read_body

    erb :'coins/index', locals: {
      coins: coins
    }
  end
  
  get '/coins/new' do
    erb :'coins/new'
  end
  
  post '/coins' do
    coin_code = params['coin_code']
    bought_date = params['bought_date']
    unit_amount = params['unit_amount']
    user_number = 1 
    

   create_coin(coin_code,bought_date,unit_amount, user_number)

    redirect '/'
  end
  
  get '/coins/:id/edit' do
    id = params['id']
    coins = run_sql("SELECT * FROM coins WHERE id = $1", [id])[0]
  
    erb :'coins/edit', locals: {
      coins: coins
    }
  end
  
  put '/coins/:id' do
    id = params['id']
    coin_code = params['coin_code']
    bought_date = params['bought_date']
    unit_amount = params['unit_amount']
  
    run_sql("UPDATE coins SET coin_code = $2, bought_date = $ 3, unit_amount = $4, user_number = $5 WHERE id = $1", [id,coin_code,bought_date,unit_amount, user_number])
    redirect '/'
  end
  
  delete '/coins/:id' do
    id = params['id']
    run_sql("DELETE FROM coins WHERE id = $1", [id])
    redirect '/'
  end
  