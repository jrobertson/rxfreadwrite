#!/usr/bin/env ruby

# file: rxfreadwrite.rb

require 'rxfreader'


module RXFReadWriteModule
  include RXFRead


  class DirX

    def self.glob(s)   RXFReadWrite.glob(s)    end

  end

  def FileX.exists?(filename)

    type = FileX.filetype(filename)

    filex = case type
    when :file
      File
    when :dfs
      DfsFile
    else
      nil
    end

    return nil unless filex

    filex.exists? filename

  end


  def FileX.filetype(x)

    return :string if x.lines.length > 1

    case x
    when /^https?:\/\//
      :http
    when /^dfs:\/\//
      :dfs
    when /^file:\/\//
      :file
    else

      if File.exists?(x) then
        :file
      else
        :text
      end

    end
  end

  def FileX.touch(s, mtime: Time.now)
    RXFReadWrite.touch(s, mtime: mtime)
  end

  def FileX.write(x, s)
    RXFReadWrite.write(x, s)
  end
end


class RXFReadWriteException < Exception
end

class RXFReadWrite < RXFReader
  using ColouredText

  def self.glob(s)

    if s[/^dfs:\/\//] then
      DfsFile.glob(s)
    else
      Dir.glob(s)
    end

  end

  def self.touch(filename, mtime: Time.now)

    case filename[/^\w+(?=:\/\/)/]
    when 'dfs'
      DfsFile.touch filename, mtime: mtime
    else
      FileUtils.touch filename, mtime: mtime
    end

  end

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
