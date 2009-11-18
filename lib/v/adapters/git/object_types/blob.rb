module V
  module Adapters
    module Git
      class Blob < ObjectType

        def content(object)
          object.environment.show object.name, :pretty => :raw
        end

        def path(parent, basename)
          parent.path basename
        end

        def [](object, *args)
          object.content[*args]
        end

        Object.register_type :blob => instance
        Object.register_methods :[]

      end
    end
  end
end
