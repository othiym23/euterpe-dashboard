module Euterpe
  module Dashboard
    class DiscBucket < ActiveRecord::Base
      def DiscBucket.changed?(path)
        bucket = DiscBucket.find_by_path(path)
        
        if bucket
          if bucket.changed?
            if File.exists?(bucket.path)
              bucket.file_created_on = File.stat(path).ctime
              bucket.file_updated_on = File.stat(path).mtime
              bucket.save
              
              bucket
            else
              bucket.delete
              nil
            end
          else
            nil
          end
        else
          bucket = DiscBucket.new
          bucket.path = path
          bucket.file_created_on = File.stat(path).ctime
          bucket.file_updated_on = File.stat(path).mtime
          bucket.save
          
          bucket
        end
      end
      
      def changed?
        file_updated_on != File.stat(path).mtime
      end
    end
  end
end