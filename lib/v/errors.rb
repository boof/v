module V
  class ERROR < RuntimeError
    # otherwise I get these stupid parenthesis warnings...
    def self.raise(*args)
      target = Thread === args.last ? args.pop : Kernel
      target.raise new(*args)
    end
  end
  class ENOTREPO < ERROR
    def initialize
      super 'repository do not exist'
    end
  end
  class ENOTWTREE < ERROR
    def initialize
      super 'operation must be run in a work tree'
    end
  end
  class ENOOP < ERROR
    def initialize(op_sym)
      super "undefined operation `#{ op_sym }'"
    end
  end
  class ECMDNOFO
    def initialize(command)
      super "#{ command }: command not found"
    end
  end
  class EUNREV < ERROR
    def initialize
      super 'unknown revision or path not in the working tree'
    end
  end
  class ECLOSED < ERROR
    def initialize
      super 'worker queue was closed already'
    end
  end
end
