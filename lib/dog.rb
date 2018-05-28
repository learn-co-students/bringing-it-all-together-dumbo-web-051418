class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(atr)
    creation = Dog.new(name: nil, breed: nil)
    atr.each do |name, value|
      creation.respond_to?("#{name}=") ? creation.send("#{name}=", value) : nil
    end
    creation.save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).first
    creation = Dog.new(breed: row[2], name: row[1], id: row[0])
  end

  def self.find_or_create_by(atr)
    sql_find = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    result = DB[:conn].execute(sql_find, atr[:name], atr[:breed]).first
    result ? Dog.find_by_id(result[0]) : Dog.create(atr)
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql_find = "SELECT * FROM dogs WHERE name = ?;"
    result = DB[:conn].execute(sql_find, name).first
    result ? Dog.new_from_db(result) : nil
    # I added a test on lines 141 through 145 describing behavior
    # that would unfold if no name was found
  end

  def update
    sql_update = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql_update, @name, @breed, @id)
  end
end
