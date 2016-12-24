require "db"
require "kemal"
require "kemal-session"
require "redis"

macro db_model(name, *properties)
  {% for p in properties %}
    {% if !p.is_a?(TypeDeclaration) %}
      raise "ERROR: Only type declaration is accepted for db_model"
    {% end %}
  {% end %}

    record {{name.id}}, {{*properties}} do    

    def self.query(db, q : String)
      models = [] of self
      
      db.query(q) do |rows|
        rows.each do
          models << read(rows)
        end
      end
      models
    end
    
    def self.read(row)
      new(
        {% for p in properties %}
          {% if p.is_a?(TypeDeclaration) %}
            row.read({{p.type}}).as({{p.type}}),
          {% end %}
        {% end %}
      )
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

  def self.set_cache(key, value)
    @@redis.set(key, value)
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

class DebuggableDB

  def initialize(uri, debug_mode : Bool)
    @@db = DB.open(uri)
    @@mode = debug_mode
  end

  def exec(q : String)
    puts q
    @@db.exec q
  end

  def query(q : String)
    puts q
    @@db.query q
  end
end
