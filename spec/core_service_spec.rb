require File.join(File.dirname(__FILE__), 'test_app/spec/spec_helper')

describe "core_service" do

  class App
    attr_accessor :name, :url, :api, :database
    def attributes; {}; end
  end

  describe "reset_config" do
    it "should post info to core service unless it is core" do
      CoreService.should_receive(:post).once.and_return(true)
      CoreService.reset_config
    end

    it "should save to database if is core" do
      CoreService.stub!(:in_core_app?).and_return(true)

      app = App.new
      app.stub!(:update_attributes).and_return(true)
      App.should_receive(:find_or_create_by_name).once.and_return(app)
      CoreService.reset_config
    end
  end

  describe "app" do

    it "should find configration by service unless it is core" do
      CoreService.should_receive(:find).once.and_return(App.new)
      CoreService.app(:app_name)
    end

    it "should find configration from database if it is core" do
      CoreService.stub!(:in_core_app?).and_return(true)

      App.should_receive(:find_by_name).once.with("app_name").and_return(App.new)
      CoreService.app(:app_name)
    end

    it "should find configration from config file for predefined" do
      CoreService.app(:article).url.should == "http://www.idapted.com/article"
    end
  end
end 

