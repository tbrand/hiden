class MockRow
  def self.read(type) : DB::Any
    case type.to_s
    when "Int32"
      return 1
    when "String"
      return "name"
    end
    puts "come here"
    nil
  end
end

class MockRowArray < Array(MockRow)

  def each(&block)
    yield
  end
  
  def read(type) : DB::Any
    MockRow.read(type)
  end
end

class MockDB
  def self.query(q : String, &block)
    yield MockRowArray.new
  end
end
