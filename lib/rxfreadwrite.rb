#!/usr/bin/env ruby

# file: rxfreadwrite.rb

require 'rxfreader'


module RXFReadWriteModule
  include RXFRead

  def FileX.write(x, s)
    RXFReadWrite.write(x, s)
  end
end


class RXFReadWriteException < Exception
end

class RXFReadWrite < RXFReader
  using ColouredText

  def self.write(location, s=nil)

    case location
    when /^dfs:\/\//

      DfsFile.write location, s

    else

      if DfsFile.exists?(File.dirname(location)) then
        DfsFile.write location, s
      else
        File.write(location, s)
      end

    end

  end

end
