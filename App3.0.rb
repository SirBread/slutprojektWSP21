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

    if checkifnameexist(username) != nil
      result = getdatawithconditionhash("*","Users","Name",username)
    # result = db.execute("SELECT * FROM Users WHERE Name = ?" ,username).first
      checkpass = result["password"]
      id = result["Userid"]

      if passwordgen(checkpass,password)
        session[:ID] = id
        redirect('/home')
      else
        set_error("Lösenorden matchade inte")
        redirect("/error")
      end
    else
      set_error("Användaren finns inte")
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

  usernamecheck = getdatawithconditionhash("Name","Users","Name",username)
    if  usernamecheck == nil
      if password == passwordconf
        newpasswrd(password,username)
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
   # Hämta vänners id till vännlistan
 user_friend_ids = getdatawithcondition("Friendid", "Friends_to_users", "Userid",session[:ID])
 # Hämta vänners namn till vännlistan
  namearray = removedubblearrayandgetnames(user_friend_ids,"Name","Users")
  # Hämta grupp alla gruppid som userid är kopplat till
  groupid = getdatawithcondition("GroupId", "Group_to_users", "Userid",session[:ID])
    # Kolla vilka namn som går ihop med id:t
  namegroups = removedubblearrayandgetnamesasd(groupid,"Groupname","Groups")
  slim(:"home/home",locals:{friends:namearray, groups:namegroups})
end

get "/friend" do
  names = getdataashash("Name","Users")
  slim(:"home/Addfriend",locals:{names:names})
end

post ("/addfriend") do
  friendname=params[:friendname]
  friendid = getfirstvaluehash("Userid","Users","Name",friendname)
  if friendid != nil
    insertinto("Friends_to_users","Userid","Friendid",session[:ID],friendid)
    # db.execute("INSERT INTO Friends_to_users (Userid,Friendid) VALUES (?,?)",session[:ID],friendid)
    redirect("/home")
  else
    set_error("Användaren finns inte")
    redirect("/error")
  end
end

post("/creatgroup") do
  if params[:groupname] != nil
    if checkgroupsv2(params[:groupname]) == []
      insertintowith3arguments("Groups","Groupname",params[:groupname])
      groupid = getdatawithcondition("GroupId","Groups","Groupname",params[:groupname])
      insertinto("Group_to_users","Userid","GroupId",session[:ID],groupid)
    else 
      set_error("Gruppen finns redan")
      redirect("/error")
    end
  else
  set_error("Du skrev inget namn")
  redirect("/error")
  end
  redirect("/home")
end 


get "/group" do 
  groupname = getdataashash("Groupname","Groups")
  slim(:"home/Addgroup",locals:{names:groupname})
end


post ("/joingroup") do
  groupid = getdatawithcondition("GroupId","Groups","Groupname",params[:groupname])
  if checkgroups(session[:ID],groupid) != []
    # friendid = db.get_first_value("Select Userid FROM Users WHERE Name = ?", friendname)
    if groupid != []
      insertinto("Group_to_users","Userid","GroupId",session[:ID],groupid)
      # db.execute("INSERT INTO Friends_to_users (Userid,Friendid) VALUES (?,?)",session[:ID],friendid)
      redirect("/home")
    else
      set_error("Gruppen finns inte")
      redirect("/error")
    end
  else
    set_error("Du är redan med i denna gruppen")
    redirect("/error")
  end
end


post ("/removefriend") do
  # Remove friend
  if session[:ID] != nil
    friendid = getdatawithcondition("Userid","Users","Name",params[:friendname])
    if friendid != []
      deletefrom("Friends_to_users","Friendid","Userid",friendid,session[:ID])
      redirect("/home")
    else
      set_error("vännen finns inte")
      redirect("/error")
    end
  end
end

post("/leavegroup") do 
  if session[:ID] != nil
    groupid = getdatawithcondition("GroupId","Groups","Groupname",params[:groupname])
    if groupid != []
      deletefrom("Group_to_users","GroupId","Userid",groupid,session[:ID])
      redirect("/home")
    else
    set_error("gruppen finns inte")
    redirect("/error")
    end
  end
end


get("/admin") do 
  result = getdatawithconditionhash("admin","Users","Userid",session[:ID])
  if result == 1
  else
    set_error("Användaren är inte admin")
    redirect("/error")
  end
end