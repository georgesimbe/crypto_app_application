require './models/coin'
get '/' do
    coins = run_sql("SELECT * FROM coins")
    coin_names_array = []
    for i in coins 
      coin_names_array.push i["coin_code"]
    end 
    
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
    p session['user_id']
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
  