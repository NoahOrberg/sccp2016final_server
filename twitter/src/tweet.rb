class Tweet
  attr_accessor :db
  def initialize(db = Sequel.sqlite('./twitter_db.sqlite3'))
    db.create_table? :tweet do
      primary_key :id
      String :text
      Integer :user_id
      String :name
      Time :create_time
    end
    @t_tweet  = db[:tweet]
    db.create_table? :user do
      primary_key :id
      String :name
      String :password
      String :salt
      Time :create_time
    end
    @t_user   = db[:user]
  end
  def getAllTweets
    @t_tweet.all
  end
  def getUserTweets(params)
    @t_tweet.where(id: params[:id]).all
  end
  def tweet(params)
    userinfo = @t_user.where(id: params[:user_id]).all
    if userinfo.empty? then
      return {}
    end
    data = {text: params[:text], user_id: params[:user_id], name: userinfo[0][:name], create_time: Time.now.year.to_s+'-'+Time.now.month.to_s+'-'+Time.now.day.to_s+' '+Time.now.hour.to_s+':'+Time.now.min.to_s+':'+Time.now.sec.to_s+' '+Time.now.utc_offset.to_s}
    id = @t_tweet.insert(data)
    data[:id] = id
    data
  end
  def getUserTimeline(user_id)
    id_list = Follow.new.getFollowersId(user_id).map{|item| item[:follow_id]}
    id_list.push(user_id.to_i)
    @t_tweet.where(:user_id => id_list).all
  end
end
