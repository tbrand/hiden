
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
