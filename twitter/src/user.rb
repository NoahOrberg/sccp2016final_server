require 'sequel'
require 'json'

class User
  attr_accessor :db
  def initialize(db = Sequel.sqlite('./twitter_db.sqlite3'))
    db.create_table? :user do
      primary_key :id
      String :name
      String :password
      String :salt
      Time :create_time
    end
    @t_user   = db[:user]
  end
  def getAllUser
    @t_user.all
  end
  def getUserName(name)
    @t_user.where(name: name).all
  end
  def getUser(id)
    @t_user.where(id: id).all
  end
  def addUser(params)
    salt = 'AAA'
    user_id = @t_user.insert(name: params[:name], password: params[:password], salt: salt, create_time: Time.now.year.to_s+'-'+Time.now.month.to_s+'-'+Time.now.day.to_s+' '+Time.now.hour.to_s+':'+Time.now.min.to_s+':'+Time.now.sec.to_s+' '+Time.now.utc_offset.to_s)
    {id: user_id}
  end
  # def save
  # end
  # def find(id)
  # end
  # def auth(name, password)
  # end
  # def unfollowers(user_id)
  # end
end

