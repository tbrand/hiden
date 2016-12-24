require "kemal"
require "kemal-session"
require "redis"
require "db"

class DebuggableDB

  @db : DB::Database|Nil
  @mode : Bool = true

  def initialize(uri, debug_mode : Bool)
    @db = DB.open(uri)
    @mode = debug_mode
  end

  def exec(q : String)
    puts "\e[33m[Query]\e[m #{q}" if @mode
    @db.as(DB::Database).exec q
  end
  
  def query(q : String, &block)
    puts "\e[33m[Query]\e[m #{q}" if @mode
    @db.as(DB::Database).query(q) do |rows|
      yield rows
    end
  end
end

macro redis_cache
  
  @@redis = Redis.new

  def self.get_cache(key, &block)
    
    val = @@redis.get(key)
    
    if val.nil?
      val = yield if val.nil?
      @@redis.set(key, val)
    end
    
    val
  end

  def self.get_cache(key)
    @@redis.get(key)
  end

  def self.set_cache(key, value)
    @@redis.set(key, value)
  end

  def self.cache_exists?(key)
    !@@redis.get(key).nil?
  end

  def self.clean_cache(key)
    @@redis.del(key)
  end

  def self.clean_cache
    @@redis.keys("*").each do |key|
      @@redis.del(key)
    end
  end
end

def flash_set(env, msg : String)
  env.session.string("__flash", msg)
end

def flash_get(env)
  msg = env.session.string?("__flash")
  msg = "" if msg.nil?
  env.session.string("__flash", "")
  msg
end
