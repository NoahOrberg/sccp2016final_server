require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'net/http'
require 'uri'
require 'json'

# Sinatra Main controller
class MainApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end
  use Rack::Session::Pool, expire_after: 2_592_000
  configure do
    set :stat, {}
  end
  get '/' do
    redirect 'login'
  end
  # register
  get '/register' do #{{{
    erb :register
  end
  #}}}
  post '/register' do #{{{
    uri = URI.parse("http://localhost:9393/users")
    https = Net::HTTP.new(uri.host, uri.port)
    # https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    payload = {
         name: params[:name],
         password: params[:password]
    }.to_json
    req.body = payload
    res = https.request(req)
    res = JSON.parse(res.body, {:symbolize_names => true})
    if res.include?(:error) then
      redirect '/register'
    else
      redirect '/login'
    end
  end
  #}}}
  
  # login
  get '/login' do #{{{
    erb :login
  end
  #}}}
  # -> auth 
  post '/auth' do #{{{
    @name = params[:name]
    @pass = params[:password]
    uri = URI.parse("http://localhost:9393/auth")
    https = Net::HTTP.new(uri.host, uri.port)
    # https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    payload = {
         name: @name,
         password: @pass
    }.to_json
    req.body = payload
    res = https.request(req)
    res = JSON.parse(res.body, {:symbolize_names => true})
    if res.include?(:error) then
      redirect '/login'
    else
      session[:id] = res[:id]
      session[:name] = res[:name]
      redirect '/timeline'
    end
  end
  #}}}
  
  # Show all users
  get '/users' do #{{{
    @title = 'All Users'
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/users')
    }
    @result = res.body
    # @result = JSON.parse(res.body, {:symbolize_names => true})
    erb :users
  end
  #}}}
  
  # Show user page
  get '/users/:name' do #{{{
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/users/'+params[:name].to_s)
    }
    userinfo = JSON.parse(res.body, {:symbolize_names => true})
    @result = res.body
    if userinfo[:id] == session[:id] then
      erb :mypage
    else
      erb :userpage
    end
  end
  #}}}
  
  # Show All user tweets 
  get '/tweets' do #{{{
    @title = 'All Tweets'
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/tweets')
    }
    @result = res.body
    # @result = JSON.parse(res.body, {:symbolize_names => true})
    erb :tweets2
  end
  #}}}
  post '/tweet' do #{{{
    if params[:text]=="" then
      redirect '/timeline'
    end
    uri = URI.parse("http://localhost:9393/tweets")
    https = Net::HTTP.new(uri.host, uri.port)
    # https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    payload = {
      user_id: session[:id].to_i,
      text: params[:text],
      reply_tweet_id: params[:reply_tweet_id].to_i
    }.to_json
    req.body = payload
    res = https.request(req)
    res = JSON.parse(res.body, {:symbolize_names => true})
    redirect '/timeline'
  end
  #}}}
  
  # Show user TimeLine
  get '/timeline' do #{{{
    @title = 'TimeLine'
    if session[:id].nil? then
      redirect '/login'
    end
    num = session[:id]
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/tweets/timeline/'+num.to_s)
    }
    res2 = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/relative/'+num.to_s+'/tweets')
    }
    @result = res.body
    @relative_result = res2.body
    @name = session[:name]
    erb :tweets
  end
  #}}}
  
  # Unfollow user
  post '/unfollows' do #{{{
    uri = URI.parse("http://localhost:9393/unfollows")
    https = Net::HTTP.new(uri.host, uri.port)
    # https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    payload = {
      user_id: session[:id].to_i,
      follow_id: params[:follow_id].to_i
    }.to_json
    req.body = payload
    res = https.request(req)
    res = JSON.parse(res.body, {:symbolize_names => true})
    redirect '/follows'
  end
  #}}}

  # Follow user
  post '/follows' do #{{{
    uri = URI.parse("http://localhost:9393/follows")
    https = Net::HTTP.new(uri.host, uri.port)
    # https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    payload = {
      user_id: session[:id].to_i,
      follow_id: params[:follow_id].to_i
    }.to_json
    req.body = payload
    res = https.request(req)
    res = JSON.parse(res.body, {:symbolize_names => true})
    redirect '/unfollows'
  end
  #}}}

  # Show unfollow users
  get '/unfollows' do #{{{
    @title = 'UnfollowUsers'
    if session[:id].nil? then
      redirect '/login'
    end
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/users/'+session[:id].to_s+'/unfollow')
    }
    @result = res.body
    @name= session[:name]
    erb :unfollow_users
  end
  #}}}

  # Show follow users
  get '/follows' do #{{{
    @title = 'followUsers'
    if session[:id].nil? then
      redirect '/login'
    end
    res = Net::HTTP::start('localhost', 9393) {|http|
      http.get('/users/'+session[:id].to_s+'/follow')
    }
    @result = res.body
    @name= session[:name]
    erb :follow_users
  end
  #}}}
  
  # logout
  post '/logout' do #{{{
    session[:id] = nil
    session[:name] = nil
    redirect '/login'
  end
  #}}}

end
