require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
enable :sessions

def connect()
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    return db
end

def getdatawithconditionhash(x,y,z,q)
    return connect.execute("SELECT #{x} FROM #{y} WHERE #{z} = ?",q).first 
end

def getdataashash(x,y)
    connect.execute("SELECT #{x} FROM #{y}")
end

def getdatawithcondition(x,y,z,q)
    connect.results_as_hash = false
    return connect.execute("SELECT #{x} FROM #{y} WHERE #{z} = ?" ,q).first 
end

def passwordgen(x,y)
    connect.results_as_hash = false
    if BCrypt::Password.new(x) == y
        return true
    else
        return false
    end
end

def newpasswrd(x)
    scrambledpsw = BCrypt::Password.create(x)
    insertinto(Users,Name,password,username,scrambledpsw)
end
def removedubblearrayandgetnames(x)
    namearray = x.map do |e|
        place = connect.execute("SELECT Name FROM Users WHERE Userid = ?", e)
        place[0]
    end
    return namearray
end

def checkifadmin(x)
    if connect.execute("SELECT admin FROM Users WHERE Userid = ?", x) == 1
        return true
    else
        return false
    end
end

def getfirstvaluehash(x,y,z,q)
    return connect.get_first_value("Select ? FROM ? WHERE ? = ?",x,y,z,q)
end

def insertinto(x,y,z,q,g)
    connect.execute("INSERT INTO ? (?,?) VALUES (?,?)",x,y,z,q,g)
end    