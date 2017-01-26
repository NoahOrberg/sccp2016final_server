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

  get '/login' do
    erb :login
  end

  post '/auth' do
    @name = params[:name]
    @pass = params[:pass]
    uri = URI.parse("http://localhost:9393/auth")
    https = Net::HTTP.new(uri.host, uri.port)
     
    # https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    payload = {
         name: @name,
         pass: @pass
    }.to_json
    req.body = payload # リクエストボデーにJSONをセット
    res = https.request(req)
    res = JSON.parse(res.body, {:symbolize_names => true})
    p res.class
    p res
    if res.include?(:error) then
      redirect '/login'
    else
      session[:id] = res[0][:id]
      session[:name] = res[0][:name]
      redirect '/timeline'
    end
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
    erb :tweets2
  end
  
  get '/timeline' do
    @title = 'TimeLine'
    num = session[:id] # target: user_id -- いずれログインしているユーザに自動で書き換えるようにする。
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


