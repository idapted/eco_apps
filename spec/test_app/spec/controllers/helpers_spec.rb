require File.join(File.dirname(__FILE__), '../spec_helper')

describe ApplicationController do

  describe "url_of" do
    before do
      Rails.stub!(:env).and_return("development")
    end

    it "should get url from app's configration" do
      controller.url_of(:article, :comments, :article_id => 1).should == "http://www.example.com/article/articles/1/comments"
      controller.url_of(:article, :comments, :article_id => 1, :params=>{:category=>"good"}).should == "http://www.example.com/article/articles/1/comments?category=good"
    end
  end

  describe "ip_limited_access" do
    before do
      require 'netaddr'
      Rails.stub!(:env).and_return("production")
      INTRANET_IP = [NetAddr::CIDR.create("192.168.1.1/24")]
      ApplicationController.ip_limited_access
    end

    it "should display access denied for illegal access" do
      get :test
      response.body.should == "Access Denied!"
    end

    it "should response successfully for legal access" do
      request.stub!(:remote_ip).and_return("192.168.1.12")
      get :test
      response.body.should == "test"
    end
  end

end 

