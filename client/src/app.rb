require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'net/http'
require 'json'

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
  
  get '/users' do
    @title = 'All Users'
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/users')
    }
    @result = res.body
    # @result = JSON.parse(res.body, {:symbolize_names => true})
    erb :users
  end

  get '/tweets' do
    @title = 'All Tweets'
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/tweets')
    }
    @result = res.body
    # @result = JSON.parse(res.body, {:symbolize_names => true})
    erb :tweets
  end
  
  get '/timeline' do
    @title = 'TimeLine'
    num = 2 # target user_id -- いずれログインしているユーザに自動で書き換えるようにする。
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/tweets/timeline/'+num.to_s)
    }
    @result = res.body
    erb :tweets
  end
  get '/users/register' do
    erb :register
  end

end


