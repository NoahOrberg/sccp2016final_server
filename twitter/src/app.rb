require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'json'
require 'sequel'
require_relative 'user.rb'
require_relative 'tweet.rb'
require_relative 'follow.rb'

# Sinatra Main controller
class MainApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end
  
  configure do
    set :stat, {}
  end
  
  get '/' do
    "Hello"
  end

  # get all user infomation
  get '/users' do
    status 200
    json User.new.getAllUser
  end

  # get user infomation 
  get '/users/:id' do
    res = User.new.getUser(params[:id].to_i)
    if res.empty? then
      status 400
      json ({error: "The user does not exist."})
    else
      status 200
      json res
    end
  end

  # get all tweet infomation
  get '/tweets' do
    status 200
    json Tweet.new.getAllTweets
  end

  # get user tweets
  get '/tweets/:id' do
    status 200
    json Tweet.new.getUserTweets(params)
  end

  # post tweet
  # json format is { user_id: 1, text: "foo" }
  post '/tweets', provides: :json do
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    res = Tweet.new.tweet(params)
    if res.empty? then
      res = {error: "The tweet user does not exist."}
    end
    json res
  end

  # post new user infomation
  # json format is { name: "foo", password: "pass1" }
  post '/users', provides: :json do
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    if User.new.getAllUser.map{|hash| hash[:name]}.include?(params[:name]) then
      status 400
      json ({error: "The user already exists."})
    else
      status 200
      json User.new.addUser(params)
    end
  end

  # get all follow infomation
  get '/follows' do
    status 200
    json Follow.new.getAllFollows
  end

  # post follow infomation
  # json format is {follow_id: x, user_id: y}
  # It's mean, y =follow=> x
  post '/follows', provides: :json do
    status 200
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    json Follow.new.followUser(params)
  end

  # post unfollow infomation
  # json format is {follow_id: x, user_id: y}
  # It's mean, y =unfollow=> x
  post '/unfollows', provides: :json do
    status 200
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    json Follow.new.unFollowUser(params)
  end
  get '/tweets/timeline/:user_id' do
    user_data = User.new.getUser(params[:user_id])
    if user_data.empty? then
      status 400
      json ({error: "The tweet user does not exist."})
    else 
      status 200
      json Tweet.new.getUserTimeline(params[:user_id])
    end
  end
  # # # # # # # # # # # # # # # # # # # # # # # # #
  # -- The following methods are incomplete.... ;(
  # # # # # # # # # # # # # # # # # # # # # # # # #
  get '/users/:id/unfollow' do

  end
end


