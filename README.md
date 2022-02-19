# RXFReadWrite example

    class Fun
      include RXFReadWriteModule


      def go()
        FileX.write 'dfs://dfs.home/tmp/foo123.txt', 'hey ho!'
      end
      def go2()
        FileX.read 'dfs://dfs.home/tmp/foo123.txt'
      end
    end

    fun = Fun.new
    puts fun.go2
    puts fun.go


