class Mp3Info 
  module HashKeys #:nodoc:
    ### lets you specify hash["key"] as hash.key
    ### this came from CodingInRuby on RubyGarden
    ### http://wiki.rubygarden.org/Ruby/page/show/RubyIdioms
    def method_missing(meth,*args)
      m = meth.id2name
      if /=$/ =~ m
        if args.length < 2
          if args[0].is_a? ID3V24::Frame
            self[m.chop] = args[0]
          elsif args[0].is_a? Array
            list = []
            args[0].each do |thing|
              if thing.is_a? ID3V24::Frame
                list << thing
              else
                list << ID3V24::Frame.create_frame(m.chop, thing.to_s)
              end
            end
            self[m.chop] = list
          else
            self[m.chop] = ID3V24::Frame.create_frame(m.chop, args[0].to_s)
          end
        else
          # is there any way to get here without major hackery?
          self[m.chop] = args
        end
      else
        self[m]
      end
    end
  end

  module NumericBits #:nodoc:
    ### returns the selected bit range (b, a) as a number
    ### NOTE: b > a  if not, returns 0
    def bits(b, a)
      t = 0
      b.downto(a) { |i| t += t + self[i] }
      t
    end
  end

  module Mp3FileMethods #:nodoc:
    def get32bits
      (getc << 24) + (getc << 16) + (getc << 8) + getc
    end
    def get_syncsafe
      (getc << 21) + (getc << 14) + (getc << 7) + getc
    end
  end

end
