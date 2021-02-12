require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

#1. Skapa ER + databas som kan hålla användare och todos. Fota ER-diagram, 
#   lägg i misc-mapp
#2. Skapa ett formulär för att registrerara användare.
#3. Skapa ett formulär för att logga in. Om användaren lyckas logga  
#   in: Spara information i session som håller koll på att användaren är inloggad
#4. Låt inloggad användare skapa todos i ett formulär (på en ny sida ELLER på sidan som visar todos.).
#5. Låt inloggad användare updatera och ta bort sina formulär.
#6. Lägg till felhantering (meddelande om man skriver in fel user/lösen)
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


post ("/addfriend") do
    friendname=params[:friendname]
    db.execute("INSERT INTO Friends (Friendsname,Users) VALUES (?,?)",friendname,session[:ID])
    redirect("/home")
end


get "/home" do
    db.results_as_hash = true
    dbfriends=db.execute("Select * FROM Friends WHERE Users = ?", session[:ID])
    dbgroups=db.execute("Select Groupname FROM Groups WHERE Users = ?", session[:ID])
    p dbfriends
    p dbgroups
    slim(:"home/home",locals:{friends:dbfriends, groups:dbgroups})
end