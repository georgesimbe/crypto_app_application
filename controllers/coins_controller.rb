require './models/coin'
get '/' do
    coins = run_sql("SELECT * FROM coins")
    coin_names_array = []
    coin_id_array = []
    for i in coins 
      coin_names_array.push i["coin_code"]
    end 
    
    # Get id of the code so u can edit and delete it but u need to place it in an array to parse it into the html document
    # # coin_n_array = []
    for i in coins 
      coin_id_array.push i["id"]
    end 
    p  coin_id_array

    url = URI("https://api.livecoinwatch.com/coins/map")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    
    request = Net::HTTP::Post.new(url)
    request["content-type"] = "application/json"
    request["x-api-key"] = ENV['COIN_API']
    request.body = JSON.dump({
      "codes": coin_names_array,
      "currency": "USD",
      "sort": "rank",
      "order": "ascending",
      "offset": 0,
      "limit": 0,
      "meta": true
    })
    response = https.request(request)
    # if response.code == "400"

    #     redirect '/coins/error_name'
    # end 
    result = JSON.parse(response.body)

    data_array = [] 
    data_array.push result 
    data_array.push session['user_id']
    data_array.push coin_id_array

    erb :'coins/index', locals: {
      coins: data_array
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

   create_coin(result['name'],bought_date,unit_amount, user_number)

    redirect '/'
  end
  
  get '/coins/:id/info' do
    id = params['id']
    coins = run_sql("SELECT * FROM coins WHERE id = $1", [id])[0]
    p coins['coin_code']
    crypto_coins = run_sql("SELECT * FROM coins WHERE coin_code = $1", [coins['coin_code']])
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
  