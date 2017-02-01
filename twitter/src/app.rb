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
  
  # auth user
  post '/auth', provides: :json do #{{{
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    res = User.new.getUserName(params[:name])
    if res.empty? || res[0][:password].to_s != params[:password].to_s then
      status 400
      json ({error: "The user does not exist."})
    else
      status 200
      json (res[0])
    end
  end
  #}}}

  # get all user infomation
  get '/users' do #{{{
    status 200
    json User.new.getAllUser
  end
  #}}}
  
  # get user infomation.
  get '/users/:name' do #{{{
    res = User.new.getUserName(params[:name].to_s)
    if res.empty? then
      status 400
      json ({error: "The user does not exist."})
    else
      status 200
      json (res[0])
    end
  end
  #}}}
  get '/users/:id' do #{{{
    res = User.new.getUser(params[:id].to_i)
    if res.empty? then
      status 400
      json ({error: "The user does not exist."})
    else
      status 200
      json (res[0])
    end
  end
  #}}}
  
  # post new user infomation
  # json format is { name: "foo", password: "pass1" }
  post '/users', provides: :json do #{{{
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    p params
    if User.new.getAllUser.map{|hash| hash[:name]}.include?(params[:name]) then
      status 400
      json ({error: "The user already exists."})
    else
      status 200
      json User.new.addUser(params)
    end
  end
  #}}}
  
  # get all tweet infomation
  get '/tweets' do #{{{
    status 200
    json Tweet.new.getAllTweets
  end
  #}}}

  # get user tweets
  get '/tweets/:id' do #{{{
    status 200
    json Tweet.new.getUserTweets(params)
  end
  #}}}

  # post tweet
  # json format is { user_id: 1, text: "foo", reply_tweet_id: 2 }
  post '/tweets', provides: :json do #{{{
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    res = Tweet.new.tweet(params)
    if res.include?(:error) then
      res = {error: "The tweet user does not exist."}
    end
    json res
  end
  #}}}

  # get all follow infomation
  get '/follows' do #{{{
    status 200
    json Follow.new.getAllFollows
  end
  #}}}

  # post follow infomation
  # json format is {follow_id: x, user_id: y}
  # It's mean, y =follow=> x
  post '/follows', provides: :json do #{{{
    status 200
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    json Follow.new.followUser(params)
  end
  #}}}

  # post unfollow infomation
  # json format is {follow_id: x, user_id: y}
  # It's mean, y =unfollow=> x
  post '/unfollows', provides: :json do #{{{
    status 200
    params=  JSON.parse(request.body.read, {:symbolize_names => true})
    json Follow.new.unFollowUser(params)
  end
  #}}}

  # get user timeline
  get '/tweets/timeline/:user_id' do #{{{
    user_data = User.new.getUser(params[:user_id])
    if user_data.empty? then
      status 400
      json ({error: "The tweet user does not exist."})
    else
      status 200
      json Tweet.new.getUserTimeline(params[:user_id])
    end
  end
  #}}}
  
  # get unfollow Users
  get '/users/:id/unfollow' do #{{{
    json (User.new.getAllUser.map{|itr| itr[:id]} - Follow.new.getFollow(params[:id].to_i).map{|itr| itr[:follow_id]} - [params[:id].to_i]).map{|itr| User.new.getUser(itr)[0]}
  end
  #}}}

  # # # # # # # # # # # # # # # # # # # # # # # # #
  # -- The following methods are incomplete.... ;(
  # # # # # # # # # # # # # # # # # # # # # # # # #
end
