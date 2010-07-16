require File.join(File.dirname(__FILE__), 'test_app/spec/spec_helper')

describe "active_resource" do

  describe "site=" do
    it "should set url automatically" do
      class CommentService < ActiveResource::Base
        self.site = :article
      end

      CommentService.site.to_s.should == "http://www.idapted.com/article"
    end
  end

end 

