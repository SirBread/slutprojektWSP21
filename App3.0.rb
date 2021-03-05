require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
enable :sessions
require_relative './model.rb'

def set_error(string)
  session[:error] = string
  return session[:error]
end

get('/error') do 
    session[:error]
end


# db = SQLite3::Database.new("db/databas.db")

get('/') do
  slim(:start)
end

get('/showlogin') do
  slim(:login)
end

post ("/login") do
    username=params[:username]
    password=params[:password]
  
    if username == ""
      set_error("Du skrev inget användarnamn")
      redirect('/error')
    end
  

    result = getdatawithconditionhash(*,User,Name,username) 
    # result = db.execute("SELECT * FROM Users WHERE Name = ?" ,username).first 
    checkpass = result["password"]
    id = result["Userid"]
    p id
    p checkpass
    p result
  
    if passwordgen(checkpass,password)
      session[:ID] = id
      p session[:ID]
      redirect('/home')
    else
      set_error("Lösenorden matchade inte")
      redirect("/error")
    end
end


get ("/register") do
    slim(:register)
end

post('/register/new') do
    username=params[:username]
    password=params[:password]
    passwordconf=params[:password_conf]

  usernamecheck = getdatawithconditionhash(Name,Users,Name,username)
    # usernamecheck = db.execute("SELECT Name FROM Users WHERE Name = ?" ,username)
    
    p usernamecheck
    if  usernamecheck == []
      if password == passwordconf
        newpasswrd(password)
        # scrambledpsw = BCrypt::Password.create(password)
        #db.execute("INSERT INTO Users (Name,password) VALUES (?,?)",username,scrambledpsw)
      else
        redirect("/home")
      end
    else
      set_error("Användarnamnet finns redan")
      redirect("/error")
    end
  redirect('/')
end

get "/home" do

 user_friend_ids = getdatawithcondition(Friendid, Friends_to_users, Userid,session[:ID])
  # HÄmta vänner till vännlistan
  # user_friend_ids=db.execute("SELECT Friendid FROM Friends_to_users WHERE Userid = ?",session[:ID])
  p user_friend_ids
  namearray = removedubblearrayandgetnames(user_friend_ids)
  # namearray = user_friend_ids.map do |e|
  #   place = db.execute("SELECT Name FROM Users WHERE Userid = ?", e)
  #   place[0]
  # end
  p "1"
  p namearray
  p "2"
 # Kolla vännernas namn

  # spara deras namn så dom kan visas

  # Hämta grupp

  # samma steg som vänner

  # place holder
  dbgroups = []
  slim(:"home/home",locals:{friends:namearray, groups:dbgroups})
end

get "/friend" do 

  names = getdataashash(Name,Users)
  # db.results_as_hash = true
  # names = db.execute("Select Name FROM Users")
  
  slim(:"home/Addfriend",locals:{names:names})
end

post ("/addfriend") do

  #no such bind parameter
  #FEL
  friendname=params[:friendname]
  friendid = getfirstvaluehash(Userid,Users,Name,friendname)
  # friendid = db.get_first_value("Select Userid FROM Users WHERE Name = ?", friendname)
  p friendid
  if friendid != nil
    insertinto(Friends_to_users,Userid,friendid,session[:ID],friendid)
    # db.execute("INSERT INTO Friends_to_users (Userid,Friendid) VALUES (?,?)",session[:ID],friendid)
    redirect("/home")
  else
    set_error("Användaren finns inte")
    redirect("/error")
  end
end
