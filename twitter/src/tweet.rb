class Tweet
  attr_accessor :db
  def initialize(db = Sequel.sqlite('./twitter_db.sqlite3'))
    db.create_table? :tweet do
      primary_key :id
      String :text
      Integer :user_id
      Integer :reply_tweet_id
      String :name
      Time :create_time
    end
    @t_tweet  = db[:tweet]
  end
  def getAllTweets
    @t_tweet.all
  end
  def getUserTweets(params)
    @t_tweet.where(id: params[:id]).all
  end
  def getUserTweets2(id)
    @t_tweet.where(user_id: id).all
  end
  def getRelativeTweets(id)
    @t_tweet.where(reply_tweet_id: id).all
  end
  def getMyRelativeTweets(id)
    @t_tweet.where(user_id: id).exclude(reply_tweet_id: 0).all
  end
  def tweet(params)
    userinfo = User.new.getUser(params[:user_id])
    if userinfo.empty? then
      data = {error: "This user does not exist."}
    else
      # TODO: [0] is not good....
      p params
      data = {text: params[:text], user_id: params[:user_id], name: userinfo[0][:name], reply_tweet_id: params[:reply_tweet_id], create_time: Time.now.year.to_s+'-'+Time.now.month.to_s+'-'+Time.now.day.to_s+' '+Time.now.hour.to_s+':'+Time.now.min.to_s+':'+Time.now.sec.to_s+' '+Time.now.utc_offset.to_s}
      id = @t_tweet.insert(data)
      data[:id] = id
      data
    end
  end
  def getUserTimeline(user_id)
    id_list = Follow.new.getFollowersId(user_id).map{|item| item[:follow_id]}
    id_list.push(user_id.to_i)
    @t_tweet.where(:user_id => id_list).all.sort{| a, b | b[:create_time] <=> a[:create_time]}
  end
end
