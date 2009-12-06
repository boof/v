module V
  class Worker < Thread
    class Group < ThreadGroup
      include Singleton

      def enclose
        super

        list.
          each { |worker| worker.stop! }.
          each { |worker| worker.join }
      end

      at_exit {
        if defined? Test::Unit::AutoRunner
          unless $! or Test::Unit.respond_to?(:run?) && Test::Unit.run?
            test_result = Test::Unit::AutoRunner.run
            instance.enclose
            exit test_result
          end
        else
          instance.enclose
        end
      }
    end

    @instances = {}
    def self.new(git_dir)
      @instances[git_dir] ||= super()
    end

    def initialize
      @queue = Queue.new

      super do
        while continue?
          operation, environment, thread, future = @queue.pop

          begin
            future.value = operation.call environment

          rescue Exception => e
            thread.raise e

          end if future
        end
      end

      if continue?
        Group.instance.add self
      else
        raise V::ECLOSED
      end
    end

    def enq(operation, environment)
      raise V::ECLOSED unless continue?

      thread, future = Thread.current, Future.new(self)
      @queue.enq [operation, environment, thread, future]

      future
    end

    def stop!
      @queue.push nil
    end
    def continue?
      not Group.instance.enclosed?
    end

  end
end
