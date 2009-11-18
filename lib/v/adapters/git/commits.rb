module V
  module Adapters
    module Git
      class Commits
        include Enumerable

        def initialize(environment, branch, path)
          @environment, @branch, @path = environment, branch, path
        end

        def first(*n)
          to_commit names_reversed.last(*n)
        end
        def last(*n)
          to_commit names_reversed.first(*n)
        end

        # TODO: work with chunks (see --max-count and --skip).
        def each
          commits = to_commit names_reversed
          commits.each { |commit| yield commit } if block_given?

          commits
        end

        # Returns true if name of commit is included in names of commits.
        def include?(commit)
          names_reversed.include? commit.name
        end

        # Returns the number of commits.
        def size
          names_reversed.size
        end
        alias_method :length, :size

        protected

          # Returns object names in reverse order.
          def names_reversed
            @environment.log(@path, :pretty => '%H').split "\n"
          end

          def to_commit(result)
            Array === result or
            return Commit.with(@environment, :name => result)

            result.reverse!
            result.map! { |name| Commit.with @environment, :name => name }
          end

      end
    end
  end
end
