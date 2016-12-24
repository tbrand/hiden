require "./spec_helper"
require "./mock"
require "db"

db_model User, id : Int32, name : String

describe "db_model" do
  it "define model" do
    user = User.new(1, "name")
    user.id.should eq(1)
    user.name.should eq("name")
  end
  
  it "read model from row" do
    user = User.read(MockRow)
    user.id.should eq(1)
    user.name.should eq("name")
  end
  
  it "throw query and craete array of the models" do
    users = User.query(MockDB, "dummy")
    users.size.should eq(1)
    users.first.id.should eq(1)
    users.first.name.should eq("name")
  end
end

describe "flash" do
  it "check result" do 
    flash_set(MockFlash, "ok")
    flash_get(MockFlash).should eq("ok")
  end
end

describe "redis_cache" do
  it "check cache" do
    MockCache.clean_cache("dummy")
    val = MockCache.get_cache("dummy") do
      "ok"
    end
    val.should eq("ok")
    val = MockCache.get_cache("dummy") do
      "ng"
    end
    val.should eq("ok")
    MockCache.set_cache("dummy", "ok2")
    val = MockCache.get_cache("dummy") do
      "ng"
    end
    val.should eq("ok2")
  end

  it "yield is not called if cache exists" do
    
    MockCache.clean_cache("dummy2")
    
    count = 0
    
    MockCache.get_cache("dummy2") do
      count += 1
    end

    MockCache.get_cache("dummy2") do
      count += 1
    end

    MockCache.get_cache("dummy2") do
      count += 1
    end

    count.should eq(1)
  end
end

