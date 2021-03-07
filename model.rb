require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
enable :sessions


def connecthash()
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    return db
end

def connect()
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = false
    return db
end

def checkifnameexist(q)
    return connecthash.execute("SELECT * FROM Users WHERE Name = ?",q).first
end

def getdatawithconditionhash(x,y,z,q)
    return connecthash.execute("SELECT #{x} FROM #{y} WHERE #{z} = ?",q).first 
end

def getdataashash(x,y)
    connecthash.execute("SELECT #{x} FROM #{y}")
end

def getdatawithcondition(x,y,z,q)
    return connect.execute("SELECT #{x} FROM #{y} WHERE #{z} = ?" ,q)
end

def passwordgen(x,y)
    connecthash.results_as_hash = false
    if BCrypt::Password.new(x) == y
        return true
    else
        return false
    end
end

def newpasswrd(x,y)
    scrambledpsw = BCrypt::Password.create(x)
    insertinto("Users","Name","password",y,scrambledpsw)
end
def removedubblearrayandgetnames(x,y,z)
    p x
    p y
    p z
    placeholderarray = x.map do |e|
        place = connecthash.execute("SELECT #{y} FROM #{z} WHERE Userid = ?", e)
        p place[0]
        place[0]
    end
    p placeholderarray
    return placeholderarray
end
def removedubblearrayandgetnamesasd(x,y,z)
    p x
    p y
    p z
    placeholderarray = x.map do |e|
        place = connecthash.execute("SELECT Groupname FROM Groups WHERE GroupId = ?",e)
        p place[0]
        place[0]
    end
    p placeholderarray
    return placeholderarray
end


def checkifadmin(x)
    if connecthash.execute("SELECT admin FROM Users WHERE Userid = ?", x) == 1
        return true
    else
        return false
    end
end

def getfirstvaluehash(x,y,z,q)
    return connecthash.get_first_value("Select #{x} FROM #{y} WHERE #{z} = ?",q)
end

def insertinto(x,y,z,q,g)
    connecthash.execute("INSERT INTO #{x} (#{y},#{z}) VALUES (?,?)",q,g)
end    