require 'sinatra'
require 'pg'
require './db/db'
require 'bcrypt'
require "uri"
require 'json'
require "net/http"
require 'dotenv/load'
# require './UserAccounts.rb'
require './controllers/coins_controller'
require './controllers/users_controller'
require './helpers/sessions_helper'
require './controllers/sessions_controller'

enable :sessions