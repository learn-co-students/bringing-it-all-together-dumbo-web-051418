class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def save
    if id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self. breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end

  def update
      sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_data = dog[0]
      song = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      song = self.create(name: name, breed: breed)
    end
    song
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create(attrs)
    Dog.new(attrs).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL
    row = DB[:conn].execute(sql, id).first
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL
    row = DB[:conn].execute(sql, name).first
    row.empty? ? nil : Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end
end
