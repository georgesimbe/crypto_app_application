def all_coins
    run_sql("SELECT * FROM coins ORDER BY id")
  end
  
  def create_coin(coin_code,bought_date,unit_amount, user_number)
    run_sql("INSERT INTO coins(coin_code,bought_date,unit_amount, user_number ) VALUES($1, $2, $3, $4)", [coin_code,bought_date,unit_amount, user_number])
  end
  
  def get_coin(id)
    run_sql("SELECT * FROM coins WHERE id = $1", [id])[0]
  end
  
  def update_coin(id, name, image_url)
    run_sql("UPDATE coins SET name = $2, image_url = $3 WHERE id = $1", [id, name, image_url])
  end
  
  def delete_coin(id)
    run_sql("DELETE FROM coins WHERE id = $1", [id])
  end
  