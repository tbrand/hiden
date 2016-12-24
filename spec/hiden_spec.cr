require "./spec_helper"
require "./mock"

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

  it "clean cache" do

    MockCache.set_cache("clean0", "ng")
    MockCache.set_cache("clean1", "ng")
    MockCache.set_cache("clean2", "ng")
    
    MockCache.clean_cache

    val0 = MockCache.get_cache("clean0") do
      "ok"
    end

    val1 = MockCache.get_cache("clean1") do
      "ok"
    end

    val2 = MockCache.get_cache("clean2") do
      "ok"
    end

    val0.should eq("ok")
    val1.should eq("ok")
    val2.should eq("ok")
  end

  it "cache exists?" do
    MockCache.clean_cache
    MockCache.cache_exists?("dummy").should eq(false)
    MockCache.set_cache("dummy", "ok")
    MockCache.cache_exists?("dummy").should eq(true)
  end
end
