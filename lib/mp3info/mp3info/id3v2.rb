require "mp3info/extension_modules"
require "mp3info/id3v2_frames"

# This class is not intended to be used directly
class ID3v2 < DelegateClass(Hash) 
  VERSION_MAJ = 4

  include Mp3Info::HashKeys
  
  attr_reader :io_position
  attr_reader :options
  
  def initialize(options = {})
    @options = { 
      :lang => "ENG", 
      :encoding => :iso  #language encoding bit 0 for iso_8859_1, 1 for unicode
    }
    @options.update(options)
    
    @hash = {}

    @hash_orig = {}
    super(@hash)
    @valid = false
    @version_maj = VERSION_MAJ
    @version_min = 0
  end

  def valid?
    @valid
  end

  def changed?
    @hash_orig != @hash
  end
  
  def version
    "2.#{@version_maj}.#{@version_min}"
  end

  ### gets id3v2 tag information from io
  def from_io(io)
    @io = io
    version_maj, version_min, flags = @io.read(3).unpack("CCB4")
    unsync, ext_header, experimental, footer = (0..3).collect { |i| flags[i].chr == '1' }
    raise("can't find version_maj ('#{version_maj}')") unless [2, 3, 4].include?(version_maj)
    @version_maj, @version_min = version_maj, version_min
    @valid = true
    tag2_len = @io.get_syncsafe
    case @version_maj
      when 2
        read_id3v2_2_frames(tag2_len)
      when 3,4
        # seek past extended header if present
        @io.seek(@io.get_syncsafe - 4, IO::SEEK_CUR) if ext_header
        read_id3v2_3_frames(tag2_len)
    end
    @io_position = @io.pos
    
    @hash_orig = @hash.dup
    #no more reading
    @io = nil
    # we should now have io sitting at the first MPEG frame
  end

  def to_bin
    #TODO handle of @tag2[TLEN"]
    #TODO add of crc
    #TODO add restrictions tag

    tag = ""
    @hash.each do |k, v|
      next unless v
      next if v.respond_to?("empty?") and v.empty?
      if v.is_a?(Array)
        v.each do |frame|
          data = encode_tag(k, frame)

          tag << k[0,4]   #4 character max for a tag's key
          #tag << to_syncsafe(data.size) #+1 because of the language encoding byte
          tag << [data.size].pack("N") #+1 because of the language encoding byte
          tag << "\x00"*2 #flags
          tag << data
        end
      else
        data = encode_tag(k, v)
        
        tag << k[0,4]   #4 character max for a tag's key
        #tag << to_syncsafe(data.size) #+1 because of the language encoding byte
        tag << [data.size].pack("N") #+1 because of the language encoding byte
        tag << "\x00"*2 #flags
        tag << data
      end
    end

    tag_str = ""

    #version_maj, version_min, unsync, ext_header, experimental, footer
    tag_str << [ VERSION_MAJ, 0, "0000" ].pack("CCB4")
    tag_str << to_syncsafe(tag.size)
    tag_str << tag
    p tag_str if $DEBUG
    tag_str
  end

  private

  def encode_tag(name, value)
    puts "encode_tag(#{name.inspect}, #{value.inspect})" if $DEBUG
    value.to_s
  end

  # create an ID3v2 frame from a raw binary string
  def decode_tag(name, value)
    ID3V24::Frame.create_frame_from_string(name, value)
  end

  ### reads id3 ver 2.3.x/2.4.x frames and adds the contents to @tag2 hash
  ###  tag2_len (fixnum) = length of entire id3v2 data, as reported in header
  ### NOTE: the id3v2 header does not take padding zero's into consideration
  def read_id3v2_3_frames(tag2_len)
    loop do # there are 2 ways to end the loop
      name = @io.read(4)
      if name[0] == 0 or name == "MP3e" #bug caused by old tagging application "mp3ext" ( http://www.mutschler.de/mp3ext/ )
        @io.seek(-4, IO::SEEK_CUR)    # 1. find a padding zero,
        seek_to_v2_end
        break
      else
        #size = @file.get_syncsafe #this seems to be a bug
        size = @io.get32bits
        puts "name '#{name}' size #{size} " if $DEBUG
        @io.seek(2, IO::SEEK_CUR)     # skip flags
        add_value_to_tag2(name, size)

      end
      break if @io.pos >= tag2_len # 2. reach length from header
    end
  end    

  ### reads id3 ver 2.2.x frames and adds the contents to @tag2 hash
  ###  tag2_len (fixnum) = length of entire id3v2 data, as reported in header
  ### NOTE: the id3v2 header does not take padding zero's into consideration
  def read_id3v2_2_frames(tag2_len)
    loop do
      name = @io.read(3)
      if name[0] == 0
        @io.seek(-3, IO::SEEK_CUR)
        seek_to_v2_end
        break
      else
        size = (@io.getc << 16) + (@io.getc << 8) + @io.getc
        add_value_to_tag2(name, size)
        break if @io.pos >= tag2_len
      end
    end
  end
  
  ### Add data to tag2["name"]
  ### read lang_encoding, decode data if unicode and
  ### create an array if the key already exists in the tag
  def add_value_to_tag2(name, size)
    puts "add_value_to_tag2" if $DEBUG
    data = decode_tag(name, @io.read(size))
    if self.keys.include?(name)
      unless self[name].is_a?(Array)
        self[name] = [self[name]]
      end
      self[name] << data
    else
      self[name] = data 
    end
  end
  
  ### runs thru @file one char at a time looking for best guess of first MPEG
  ###  frame, which should be first 0xff byte after id3v2 padding zero's
  def seek_to_v2_end
    until @io.getc == 0xff
    end
    @io.seek(-1, IO::SEEK_CUR)
  end
  
  ### convert an 32 integer to a syncsafe string
  def to_syncsafe(num)
    n = ( (num<<3) & 0x7f000000 )  + ( (num<<2) & 0x7f0000 ) + ( (num<<1) & 0x7f00 ) + ( num & 0x7f )
    [n].pack("N")
  end
end
