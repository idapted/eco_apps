require File.join(File.dirname(__FILE__), '../spec_helper')

describe "acts_as_readonly" do
  describe "not test mode" do
    before do
      Rails.stub!(:env).and_return("development")
      Comment.acts_as_readonly :article
    end

    it "should read data from other database" do
      Comment.table_name.should == "article_development.comments"
    end
    
    it "should raise error for write operation" do
      lambda {Comment.create}.should raise_error(ActiveRecord::ReadOnlyRecord)
      lambda {Comment.delete_all}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe "test mode" do
    it "should generate table for comments" do
      Comment.table_name.should == "comments"
      Comment.column_names.should include("title")
    end
  end
  
end 

