require "db"
require "kemal"
require "kemal-session"

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

def flash_set(env : HTTP::Server::Context, msg : String)
  env.session.string("__flash", msg)
end

def flash_get(env : HTTP::Server::Context)
  env.session.string?("__flash")
  env.session.string("__flash", nil)
end
