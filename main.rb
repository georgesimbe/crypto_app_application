require 'sinatra'
require 'pg'
require './db/db'
require 'bcrypt'

require './controllers/coins_controller'
require './controllers/users_controller'
require './helpers/sessions_helper'
require './controllers/sessions_controller'

enable :sessions