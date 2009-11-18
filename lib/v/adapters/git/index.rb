module V
  module Adapters
    module Git
      # http://book.git-scm.com/7_the_git_index.html
      class Index
        include V::Adapters::Git

        def initialize(environment)
          @environment = environment
        end

        def add(*files)
          @environment.add *files
        end
        alias_method :<<, :add

        def include?(filename)
          @environment.ls_files(filename) !~ /^\s*$/
        end

        def +(other)
          raise NotImplementedError, 'TODO: implement Index#+(other)'
        end

        def -(other)
          other.is_a? Git::Object or
          raise ArgumentError, 'expected Git::Object'

          name = case other
          when Commit
            other.name
          when Tree
            other.name
          when Tag
            other.name
          when Blob
            raise NotImplementedError, 'TODO: implement Index#-(other)'
          else raise p(other)
          end

          @environment.diff_index name,
              :name_status => true, :cached => true do |out, err|
            Status.new out
          end
        end

        def commit(*args)
          @environment.commit *args
        end
        def reset(*args)
          @environment.reset *args
        end

        protected

          def assign(attrs)
            attrs.each { |k, v| instance_variable_set :"@#{ k }", v }
          end

      end
    end
  end
end
