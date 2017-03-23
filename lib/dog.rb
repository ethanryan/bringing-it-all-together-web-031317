require 'pry'

class Dog

  #DB = {:conn => SQLite3::Database.new("db/dogs.db")}
  #Whenever we want to refer to the applications connection
  #to the database, we will simply rely on DB[:conn]
  #DB[:conn]
  
  attr_accessor :name, :breed, :id

  def initialize(name: , breed: , id: nil) #hash?? ...this is intrepeted as a hash cuz of the key/value pairs.
    #name: 'name', breed: 'breed', id: nil
    @name = name
    @breed = breed
    @id = id
  end


  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end


  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end


  def save
    if self.persisted? #if instance exists...
      self.update
    else #if it doesn't exist...
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end #end if...else statement
    self
  end


  def persisted?
    !!self.id
  end


  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


  def self.create(hash)
    #binding.pry
    dog = self.new(hash)
    #dog = self.new(name, grade)
    #name = hash[:name]
    #breed = hash[:breed]
    dog.save
    dog
  end


  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    result = DB[:conn].execute(sql, id)
    result.map do |row|
      self.new_from_db(row)
    end.first #returns first from array created by map
  end #end method


  def self.new_from_db(row)
    #binding.pry
    # create a new Dog object given a row from the database
    #new_dog = self.new # self.new is the same as running Student.new
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = self.new(name:name, breed:breed, id:id) # self.new is the same as running Student.new
    new_dog  # return the newly created instance
  end




  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    AND breed = ?
    SQL
    result = DB[:conn].execute(sql,hash[:name],hash[:breed])

    if result.empty? #if dog doesn't exist in the database...
      create(hash)
    else
      new_from_db(result.first)
    end
  end


  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL

    results = DB[:conn].execute(sql,name)
    results.map do |row|
      self.new_from_db(row)
    end.first #returns first from array created by map
  end #end method


end #end class
