module V
  module Adapters
    module Git
      class Tree < ObjectType
        include Enumerable

        def self.with(environment, attrs = {})
          Object.new environment, attrs.update(:type => :tree)
        end

        LINE_RE = /^(\d{6}) (blob|tree) ([[:alnum:]]{40})\t(.+)$/
        def content(object)
          environment, name, parent = object.environment, object.name, object

          environment.ls_tree(name).split($/).
          inject({}) do |mem, line|
            mode, type, name, basename = LINE_RE.match(line).captures

#            see git help ls-tree
#            path.gsub! /(\\n|\\t|\\)/, ...

            child = Object.new environment,
                :type => type.to_sym, :name => name,
                :parent => parent, :basename => basename

            mem.update basename => child
          end
        end
        def each(object)
          object.content.values.each { |v| yield v }
        end

        def [](object, glob)
          raise NotImplementedError
        end
        def /(object, path)
          parts = path.to_s.split '/'
          parts.inject(object) { |obj, name| obj.content.fetch name }
        end

        def path(parent, *basenames)
          parent.path *basenames
        end

        Object.register_type :tree => instance
        Object.register_methods :each, :/, :[]

      end
    end
  end
end
