module V
  class Future
    instance_methods.each { |meth| undef_method(meth) unless meth =~ /\A__/ }

    def initialize(worker)
      @worker, @waiting = worker, []
    end

    def value
      while (Thread.critical = true; not defined? @value)
        Thread.current != @worker or
        raise ThreadError, 'waiting for a value in worker causes deadlock'
        @waiting << Thread.current
        Thread.stop
      end

      @value
    ensure
      Thread.critical = false
    end

    def value=(value)
      Thread.critical = true
      @value = value

      class << self
        def value; @value end
      end

      begin
        while thread = @waiting.shift
          thread.wakeup
        end
      rescue ThreadError
        retry
      ensure
        Thread.critical = false
      end
    end

    def method_missing(*params, &block)
      value.send(*params, &block)
    end

  end
end
