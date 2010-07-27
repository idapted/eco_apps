class Comment < ActiveRecord::Base
  acts_as_readonly :article
end