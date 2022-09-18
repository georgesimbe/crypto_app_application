require './models/coin'

get '/' do
    coins = run_sql("SELECT * FROM coins ORDER BY coin_code")
    coins_array = []
    coins_names_array = []
    coin_id_array = []
    for i in coins
      coins_names_array.push i["coin_code"]
      coins_array.push i 
    end 
    url = URI("https://api.livecoinwatch.com/coins/map")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    
    request = Net::HTTP::Post.new(url)
    request["content-type"] = "application/json"
    request["x-api-key"] = ENV['COIN_API']
    request.body = JSON.dump({
      "codes": coins_names_array,
      "currency": "AUD",
      "sort": "code",
      "order": "ascending",
      "offset": 0,
      "limit": 20,
      "meta": true
    })
    response = https.request(request)
    result = JSON.parse(response.body)
    coins_array_output = {}
    coins_array_output.store "db_output", coins_array

    coins_array_output['db_output'].each do |key,value|     
      coins_array_output[key] = value    
      end
 
    coins_array_output.store "api_output", result
    coins_array_output['api_output'].each do |key,value|     
      coins_array_output[key] = value    
      end
    erb :'coins/index', locals: {
      coins: coins_array_output
    }
    
  end
  
  get '/coins/new' do
    erb :'coins/new'
  end
  
  post '/coins' do
    coin_code = params['coin_code']
    bought_date = params['bought_date']
    unit_amount = params['unit_amount']
    user_number = session['user_id']
    url = URI("https://api.livecoinwatch.com/coins/single")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    
    request = Net::HTTP::Post.new(url)
    request["content-type"] = "application/json"
    request["x-api-key"] = ENV['COIN_API']
    request.body = JSON.dump({
      "currency": "USD",
      "code": coin_code.upcase,
      "meta": true
    }) 
    response = https.request(request)
    if response.code == "400"
      
        redirect '/coins/error_name'
    end 
    result = JSON.parse(response.body)

   create_coin(coin_code.upcase,bought_date,unit_amount, user_number)

    redirect '/'
  end
  
  get '/coins/:id/info' do
    id = params['id']
    user_number = session['user_id']
    coins = run_sql("SELECT * FROM coins WHERE id = $1", [id])
    for i in coins 
      p i['coin_code']
    end
    crypto_coins = run_sql("SELECT * FROM coins WHERE id = $1", [id])
    erb :'coins/info', locals: {
      coins: crypto_coins
    }
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
    user_number = session['user_id'] 
  
    run_sql("UPDATE coins SET bought_date = $2, unit_amount = $3, user_number = $4 WHERE id = $1", [id,bought_date,unit_amount, user_number])
    redirect "/coins/#{id}/edit"
  end
  
  delete '/coins/:id' do
    id = params['id']
    run_sql("DELETE FROM coins WHERE id = $1", [id])
    redirect '/'
  end


  get '/coins/error_name' do
      erb :'coins/error_name'
  end