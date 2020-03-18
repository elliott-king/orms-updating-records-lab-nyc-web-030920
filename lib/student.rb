require_relative "../config/environment.rb"

class Student
  
  attr_accessor :name, :grade, :id
  def initialize(name, grade, id=nil)
    @name = name 
    @grade = grade 
    @id = id 
  end

  def save
    if @id 
      return self.update
    end
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end
  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
  def self.create(name, grade)
    Student.new(name, grade).save
  end
  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end
end
