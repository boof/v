module V
  module Adapters
    module Git
      class Tag < ObjectType

        # Returns the name of the commit the object points to.
        def content(obj)
          path = File.join obj.environment.git_dir, %w[ refs tags ], obj.name
          File.read(path).chomp
        end

        # Returns the commit the object points to.
        def commit(object)
          Commit.with object.environment, :name => object.content
        end

        Object.register_type :tag => instance
        Object.register_methods :commit

      end
    end
  end
end
