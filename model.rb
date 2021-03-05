def connect()
    SQLite3::Database.new("db/databas.db")
end

def getdatawithconditionhash(x,y,z,q)
    connect.results_as_hash = true
    return connect.execute("SELECT x FROM y WHERE z = ?" ,q).first 
end

def getdataashash(x,y)
    connect.results_as_hash = true
    connect.execute("SELECT x FROM y")
end

def getdatawithcondition(x,y,z,q)
    connect.results_as_hash = false
    return connect.execute("SELECT x FROM y WHERE z = ?" ,q).first 
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
    connect.results_as_hash = true
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
    connect.results_as_hash = true
    return connect.get_first_value("Select x FROM y WHERE z = ?", q)
end

def insertinto(x,y,z,q,g)
    connect.results_as_hash = true
    connect.execute("INSERT INTO x (y,z) VALUES (?,?)",q,g)

end    