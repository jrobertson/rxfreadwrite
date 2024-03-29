#!/usr/bin/env ruby

# file: rxfreadwrite.rb

require 'rxfreader'
require 'drb_fileclient-readwrite'


module RXFReadWriteModule
  include RXFRead

  class DirX

    def self.chdir(s)    RXFReadWrite.chdir(s)    end
    def self.glob(s)     RXFReadWrite.glob(s)     end
    def self.mkdir(s)    RXFReadWrite.mkdir(s)    end
    def self.mkdir_p(s)  RXFReadWrite.mkdir_p(s)  end
    def self.pwd()       RXFReadWrite.pwd()       end

  end

  def FileX.chdir(s)      RXFReadWrite.chdir(s)   end

  def FileX.directory?(filename)

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

    filex.directory? filename

  end

  def FileX.exist?(s)    RXFReadWrite.exist?(s)   end
  def FileX.exists?(s)    RXFReadWrite.exist?(s)  end
  def FileX.mkdir(s)      RXFReadWrite.mkdir(s)   end
  def FileX.mkdir_p(s)    RXFReadWrite.mkdir_p(s) end
  def FileX.pwd()         RXFReadWrite.pwd()      end
  def FileX.rm(s)         RXFReadWrite.rm(s)      end

  def FileX.rm_r(s, force: false)
    RXFReadWrite.rm_r(s, force: force)
  end

  def File.rm_rf(s)       RXFReadWrite.rm_rf(s)   end

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

  @@fs = :local

  # identifies the working file system
  def self.fs()
    @@fs
  end

  def self.chdir(x)

    # We can use @@fs within chdir() to flag the current file system.
    # Allowing us to use relative paths with FileX operations instead
    # of explicitly stating the path each time. e.g. touch 'foo.txt'
    #

    if x[/^file:\/\//] or File.exist?(File.dirname(x)) then

      @@fs = :local
      FileUtils.chdir x

    elsif x[/^dfs:\/\//]

      host = x[/(?<=dfs:\/\/)[^\/]+/]
      @@fs = 'dfs://' + host
      DfsFile.chdir x

    end

  end

  def self.exist?(filename)
    #puts 'inside readwrite exists?'
    type = self.filetype(filename)

    filex = case type
    when :file
      File
    when :dfs
      DfsFile
    else
      nil
    end

    return nil unless filex

    filex.exist? filename

  end
  
  def self.exists?(filename)
    self.exist?(filename)
  end

  def self.filetype(x)

    return :string if x.lines.length > 1
    return :dfs if @@fs[0..2] == 'dfs'
    RXFReader.filetype(x)

  end

  def self.glob(s)

    if s[/^dfs:\/\//] then

      basepath = s[/^(dfs:\/\/[^\/]+)/,1]
      pos = s.length - basepath.length

      DfsFile.glob(s).map do |x|
        pos2 = x =~ /#{s[pos..-1]}/
        basepath + x[pos2..-1]
      end

    else
      Dir.glob(s)
    end

  end

  def self.mkdir(x)

    if x[/^file:\/\//] or File.exist?(File.dirname(x)) then
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

  def self.pwd()
    DfsFile.pwd
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

  def self.rm_rf(filename)
    rm_r(filename, force: true)
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

      if DfsFile.exist?(File.dirname(location)) then
        DfsFile.write location, s
      else
        File.write(location, s)
      end

    end

  end

end
