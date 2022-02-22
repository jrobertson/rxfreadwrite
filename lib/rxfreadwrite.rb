#!/usr/bin/env ruby

# file: rxfreadwrite.rb

require 'rxfreader'
require 'drb_fileclient-readwrite'


module RXFReadWriteModule
  include RXFRead

  class DirX

    def self.glob(s)     RXFReadWrite.glob(s)     end
    def self.mkdir(s)    RXFReadWrite.mkdir(s)    end
    def self.mkdir_p(s)  RXFReadWrite.mkdir_p(s)  end

  end

  def FileX.mkdir(s)      RXFReadWrite.mkdir(s)       end
  def FileX.mkdir_p(s)    RXFReadWrite.mkdir_p(s)     end
  def FileX.rm(s)         RXFReadWrite.rm(s)          end

  def FileX.rm_r(s, force: false)
    RXFReadWrite.rm_r(s, force: force)
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

  def self.mkdir(x)

    if x[/^file:\/\//] or File.exists?(File.dirname(x)) then
      FileUtils.mkdir x
    elsif x[/^dfs:\/\//]
      DfsFile.mkdir x
    end

  end

  def self.mkdir_p(x)

    if x[/^dfs:\/\//] then
      DfsFile.mkdir_p x
    else
      FileUtils.mkdir_p x
    end

  end

  def self.rm(filename)

    case filename[/^\w+(?=:\/\/)/]
    when 'dfs'
      DfsFile.rm filename
    else

      if File.basename(filename) =~ /\*/ then

        Dir.glob(filename).each do |file|

          begin
            FileUtils.rm file
          rescue
            puts ('RXFReadWrite#rm: ' + file + ' is a Directory').warning
          end

        end

      else
        FileUtils.rm filename
      end

    end

  end

  def self.rm_r(filename, force: false)

    case filename[/^\w+(?=:\/\/)/]
    when 'dfs'
      DfsFile.rm_r filename, force: force
    else

      if File.basename(filename) =~ /\*/ then

        Dir.glob(filename).each do |file|

          begin
            FileUtils.rm_r file, force: force
          rescue
            puts ('RXFReadWrite#rm_r: ' + file + ' is a Directory').warning
          end

        end

      else
        FileUtils.rm_r filename, force: force
      end

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
