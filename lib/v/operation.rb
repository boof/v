module V

  class Operations < Module

    def initialize(load_path)
      @load_path, @operations = load_path, {}
    end

    def included(base)
      base.const_set :Operations, self

      class_path = File.join @load_path, 'operations', '**', '*'
      Dir[ class_path ].each { |p| require p }
    end

    TO_SYM_DEFN = %q"def self.to_sym; :'%s' end"
    DEF_SHORTCUT = <<-RUBY
      def %s(*args, &callback)
        schedule (self.class)::Operations.new(:%s, *args, &callback)
      end
    RUBY
    def operation(op_sym, &defn)
      this_module = self
      op = Class.new(Operation) { const_set :Operations, this_module }
      op.class_eval TO_SYM_DEFN % "#{ op_sym }".gsub('_', '-')
      op.class_eval(&defn)

      module_eval DEF_SHORTCUT % [ op_sym, op_sym ]

      @operations[ op_sym ] = op
    end
    def new(op_sym, *args, &callback)
      op_class = @operations[op_sym] or
      V::ENOOP.raise(op_sym)

      op_class.new(*args, &callback)
    end

  end

  class Operation
    attr_reader :arguments

    def self.arguments(&defn)
      const_set :Arguments, Arguments.new(self, &defn)
    end

    def initialize(*arguments, &callback)
      @arguments, @callback = arguments, callback
      @hooks = Hash.new { |h, k| h[k] = [] }
    end

    def call(environment)
      @hooks[:pre].all? { |hook| hook[environment] != false } or throw :pre
      value = run environment
      @hooks[:post].all? { |hook| hook[environment] != false } or throw :post

      @callback ? @callback[value] : value
    end

    def run(value)
      raise NotImplementedError
    end

    def exec(environment)
      sh = "#{ environment } #{ self }"
      logger.info sh

      stdout, stderr = Open3.popen3(sh) { |_, *oe| oe.map { |io| io.read } }
      logger.debug stdout unless stdout.empty?
      logger.error stderr unless stderr.empty?

      return stdout, stderr
    end

    def to_s
      (self.class)::Arguments % @arguments
    end

    # TODO: replace this stub
    require 'logger'
    @@logger = Logger.new STDERR
    @@logger.level = Logger::INFO

    def self.logger
      @@logger
    end
    def logger
      self.class.logger
    end

  end

end
