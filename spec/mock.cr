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

class MockFlash

  def self.session
    MockSession
  end
end

class MockSession

  @@hash = {} of String => String
  
  def self.string(key, value)
    @@hash[key] = value
  end

  def self.string?(key)
    @@hash[key]
  end
end

class MockCache
  redis_cache
end
