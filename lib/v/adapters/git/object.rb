module V
  module Adapters
    module Git
      class ObjectType
        include Singleton

        # Returns true if other is a Git::Object and has the same type, false
        # otherwise.
        def ===(object)
          object.is_a? Git::Object and object.type == self
        end

        # See ObjectType#===.
        def self.===(object)
          instance === object
        end

        def content(object)
          raise NotImplementedError
        end
        def to_s(object = nil)
          object ? object.name : self.class.name
        end
      end

      # http://book.git-scm.com/1_the_git_object_model.html
      class Object

        DEFN = 'def %s(*args, &block) type.%s self, *args, &block end'
        def self.register_methods(*methods)
          methods.each { |method| class_eval DEFN.gsub('%s', method.to_s) }
        end
        @@types = {}
        def self.register_type(type)
          @@types.update type
        end

        attr_reader :name, :environment

        def initialize(environment, attrs)
          @environment = environment
          assign attrs
        end

        # Keep this lazy! Most objects only need a name.
        def type
          @@types.fetch @type
        end

        # Content depends on type. Since this object is typecasted on demand
        # content can be assigned during initialize (e.g. after commit).
        def content(reload = false)
          @content = type.content self if reload or not defined? @content
          @content
        end
        def size
          content.size
        end
        alias_method :length, :size

        def to_s
          type.to_s self
        end

        INSPECT_EXCLUDES = [:'@content', :'@name', :'@type']
        def inspect
          attrs = instance_variables.inject([]) { |m, i|
            if INSPECT_EXCLUDES.include? :"#{ i }" then m
            else
              m << "#{ i }=#{ instance_variable_get(:"#{ i }").inspect }"
            end
          } * ' '
          type = "#{ @type }".capitalize

          "#<Git::#{ type }:#{ @name } #{ attrs } @content=[...]>"
        end

        # Returns the path to the object in the current root.
        def path(*basenames)
          type.path @parent, @basenames, *basenames
        end

        # Returns true if the other object has the same type and name, false
        # otherwise.
        def ==(other)
          type === other and name == other.name
        end

        protected

          def assign(attrs)
            attrs.each { |k, v| instance_variable_set :"@#{ k }", v }
          end

      end
    end
  end
end

begin
  __dir__ = File.dirname __FILE__
  %w[ commit tree blob tag ].
  each { |basename| require "#{ __dir__ }/object_types/#{ basename }" }
end
