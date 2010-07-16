require File.join(File.dirname(__FILE__), 'test_app/spec/spec_helper')

describe "helpers" do

  describe "url_of" do
    before do
      Rails.stub!(:env).and_return("development")
      @controller = ActionController::Base.new
    end

    it "should get url from app's configration" do
      @controller.url_of(:article, :comments, :article_id => 1).should == "http://www.idapted.com/article/articles/1/comments"
      @controller.url_of(:article, :comments, :article_id => 1, :params=>{:category=>"good"}).should == "http://www.idapted.com/article/articles/1/comments?category=good"
    end
  end

end 

