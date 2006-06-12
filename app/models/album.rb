class Album < ActiveRecord::Base
  has_many :discs
end
