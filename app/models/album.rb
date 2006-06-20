module Euterpe
  module Dashboard
    class Album < ActiveRecord::Base
      has_many :discs
      belongs_to :genre
    end
  end
end
