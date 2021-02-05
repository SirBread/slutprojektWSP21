require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions



get ("/") do 
    slim(:start)
end
get "/home" do
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    dbfriends=db.execute("Select * FROM Friends WHERE Users = ?", session[:ID])
    dbgroups=db.execute("Select Groupname FROM Groups WHERE Users = ?", session[:ID])
    p dbfriends
    p dbgroups
    slim(:"home/home",locals:{friends:dbfriends, groups:dbgroups})
end

get ("/register") do
    slim(:register)
end

post('/register/new') do
    username=params[:username]
    password=params[:password]
    passwordconf=params[:password_conf]
    if password == passwordconf
      scrambledpsw = BCrypt::Password.create(password)
      db = SQLite3::Database.new("db/databas.db")
      db.execute("INSERT INTO Users (Name,password) VALUES (?,?)",username,scrambledpsw)
    else
      redirect("/home")
    end
    redirect('/')
  end

  
post ("/login") do
    username=params[:username]
    password=params[:password]
  
    if username == ""
      set_error("Du skrev inget användarnamn")
      redirect('/error')
    end
  
    db = SQLite3::Database.new("db/databas.db")
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

post ("/addfriend") do
    friendname=params[:friendname]
    db = SQLite3::Database.new("db/databas.db")
    db.execute("INSERT INTO Friends (Friendsname,Users) VALUES (?,?)",friendname,session[:ID])
    redirect("/home")
end