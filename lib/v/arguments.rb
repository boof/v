module V
  class Arguments
    instance_methods.each { |meth| undef_method(meth) unless meth =~ /\A__/ }
    
    def initialize(op, &args)
      @op, @first_argument = op.to_sym, nil

      @slots = []
      yield self if block_given?
      @slots.freeze
    end
    
    def method_missing(argument, *defaults)
      options = Hash === defaults.last ? defaults.pop : {}
      @first_argument = argument if options[:first]

      slot = Slot.new argument, defaults, options
      @slots << slot

      slot
    end

    def <<(string)
      @slots << string
    end

    def %(args)
      opts = Hash === args.last ? args.pop : {}
      opts[@first_argument] = args.shift if @first_argument

      op_args = @slots.inject([@op]) { |ca, slot|
        if String === slot
          ca << slot
        elsif key = slot.key(opts)
          if slot.standalone? and opts[key]
            ca << slot
          else
            value = opts[key]

            if slot.defaults_to? value then ca
            else
              ca << slot.to_s % quote(value)
            end
          end
        else
          ca
        end
      }.concat args.map { |arg| quote arg }

      op_args * ' '
    end

    def inspect
      @slots.inspect
    end

    protected

      def quote(str)
        str = "#{ str }"

        str.gsub! "\'", "'\\\\''"
        str.gsub! ";", '\\;'

        "'#{ str }'"
      end

    class Slot
      attr_reader :to_sym
      def initialize(argument, defaults, options)
        @to_s, @to_sym = "#{ argument }".gsub('_', '-'), argument
        @captures = [argument]
        @options = options
        @standalone, @defaults = defaults.empty?, defaults.map { |d| d.to_s }

        @fstring = if @options[:rude] then '%s'
            elsif @options[:alias] and @standalone then '-$op'
            elsif @options[:alias] and not @standalone then '-$op %s'
            elsif not @options[:alias] and @standalone then '--$op'
            else '--$op=%s'
            end
      end
      def method_missing(sym)
        @captures << sym
        @to_s = sym.to_s if @options[:alias]
      end
      def standalone?
        @standalone
      end
      def key(opts)
        @captures.find { |cap| opts.member? cap }
      end
      def defaults_to?(value)
        @defaults.include? value.to_s
      end
      def to_s
        @fstring.sub '$op', @to_s
      end
    end

  end
end