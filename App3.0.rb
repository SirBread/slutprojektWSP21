require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

def set_error(string)
  session[:error] = string
  return session[:error]
end

get('/error') do 
    session[:error]
  end


db = SQLite3::Database.new("db/databas.db")

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
  

    db.results_as_hash = true
    result = db.execute("SELECT * FROM Users WHERE Name = ?" ,username).first 
    checkpass = result["password"]
    id = result["Userid"]
  
    if BCrypt::Password.new(checkpass) == password
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
    usernamecheck = db.execute("SELECT Name FROM Users WHERE Name = ?" ,username)
    
    p usernamecheck
    if  usernamecheck == []
      if password == passwordconf
        scrambledpsw = BCrypt::Password.create(password)
              db.execute("INSERT INTO Users (Name,password) VALUES (?,?)",username,scrambledpsw)
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
    db.results_as_hash = true
    dbfriendid=db.execute("Select Friendid FROM Friends_to_users WHERE Userid = ?", session[:ID])
    dbfriends=db.execute("Select Name FROM Users WHERE Userid = ?", dbfriendid)
    dbgroups=db.execute("Select Groupname FROM Groups WHERE Users = ?", session[:ID])
    p dbfriends
    p dbgroups
    slim(:"home/home",locals:{friends:dbfriends, groups:dbgroups})
end

get "/friend" do 
  names = db.execute("Select Name FROM Users")
  p names
  slim(:"home/Addfriend",locals:{names:names})
end

post ("/addfriend") do

  #no such bind parameter
  #FEL

  friendname=params[:friendname]
  friendid = db.execute("Select Userid FROM Users WHERE Name = ?", friendname)
  if friendid != []
    db.execute("INSERT INTO Friends_to_users (Userid,Friendid) VALUES (?,?)",session[:ID],friendid)
    redirect("/home")
  else
   set_error("Det finns ingen med det namnet")
   redirect("/error")
  end
end

