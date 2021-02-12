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

db = SQLite3::Database.new("db/todos.db")

get('/') do
  slim(:register)
end

get('/error') do 
  session[:error]
end

get('/showlogin') do
  slim(:login)
end


post('/login') do
  username=params[:username]
  password=params[:password]

  if username == ""
    set_error("Du skrev inget användarnamn")
    redirect('/error')
  end
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE name = ?" ,username).first 
  checkpass = result["password"]
  id = result["ID"]

  if BCrypt::Password.new(checkpass) == password
    session[:ID] = id
    p session[:ID]
    redirect('/todo')
  else
    set_error("Lösenorden matchade inte")
    redirect("/error")
  end
 
end

get '/update_todos' do
  slim(:"todos/update")
end

post("/update") do
  update_todo = params[:update_todo]
  todo_updated = params[:todo_updated]
  id = session[:ID].to_i 
  db.results_as_hash = true
  result = db.execute("UPDATE todos SET content =REPLACE(content, ?, ?) WHERE userid = ?",update_todo, todo_updated, id)
  redirect('/todo')
end

post('/delete') do
  todo_delete = params[:todo_delete]
  id = session[:ID].to_i 
  db.results_as_hash = true
  db.execute("DELETE FROM todos WHERE content = ?", todo_delete)
  redirect('/todo')
end

get("/todo") do 
  id = session[:ID].to_i
  db.results_as_hash = true
  dbresult = db.execute("SELECT * FROM todos WHERE userid = ?" ,id)
  p "Här är alla dina todos #{dbresult}"
  slim(:"todos/index",locals:{todos:dbresult})
end

post("/maketodo") do 
  id = session[:ID].to_i
  task = params[:task]
  db.results_as_hash = true
  if task != nil
    db.execute("INSERT INTO todos (content, userid) VALUES (?,?)", task, id)
    redirect('/todo')
  else
    set_error("du skrev ingen todo")
    redirect('/error')
  end

end

post('/register/new') do
  username=params[:username]
  password=params[:password]
  passwordconf=params[:password_conf]
  if password == passwordconf
    scrambledpsw = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/todos.db")
    db.execute("INSERT INTO users (name,password) VALUES (?,?)",username,scrambledpsw)
  else
    slim(:error)
  end
  redirect('/')
end
