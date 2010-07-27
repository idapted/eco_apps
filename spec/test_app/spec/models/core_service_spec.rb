require File.join(File.dirname(__FILE__), '../spec_helper')

describe "core_service" do

  describe "reset_config" do
    it "should post info to core service unless it is core" do
      CoreService.should_receive(:post).once.and_return(true)
      CoreService.reset_config
    end

    it "should save to database if is core" do
      CoreService.stub!(:in_master_app?).and_return(true)
      CoreService.reset_config
      App.first.name.should == "test_app"
    end
  end

  describe "app" do
    it "should find configration by service unless it is core" do
      CoreService.should_receive(:find).once.and_return(App.new)
      CoreService.app(:app_name)
    end

    it "should find configration from database if it is core" do
      CoreService.stub!(:in_master_app?).and_return(true)
      CoreService.reset_config
      CoreService.app(:test_app).should == App.first
    end

    it "should find configration from config file for predefined" do
      CoreService.app(:article).url.should == "http://www.example.com/article"
    end
  end
end 

