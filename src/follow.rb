class Follow
  attr_accessor :db
  def initialize(db = Sequel.sqlite('./twitter_db.sqlite3'))
    db.create_table? :follow do
      primary_key :id
      Integer :follow_id
      Integer :user_id
      Time :create_time
    end
    @t_follow  = db[:follow]
  end
  def getAllFollows
    @t_follow.all
  end
  def followUser(params)
    id = @t_follow.insert(follow_id: params[:follow_id], user_id: params[:user_id], create_time: Time.now.year.to_s+'-'+Time.now.month.to_s+'-'+Time.now.day.to_s+' '+Time.now.hour.to_s+':'+Time.now.min.to_s+':'+Time.now.sec.to_s+' '+Time.now.utc_offset.to_s)
    {id: id, follow_id: params[:follow_id], user_id: params[:user_id]}
  end
  def unFollowUser(params)
    res = @t_follow.where(follow_id: params[:follow_id], user_id: params[:user_id]).delete
    res != 0 ? {res: "ok"} : {res: "error"}
  end
  def getFollowersId(id)
    @t_follow.where(user_id: id).all
  end
  def getFollow(id)
    @t_follow.where(user_id: id).all
  end
end

