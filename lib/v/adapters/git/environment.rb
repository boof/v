module V
  module Adapters
    module Git
      class Environment
        include Operations

        attr_reader :to_s, :bare, :work_tree, :git_dir, :branches, :index

        def self.which_git=(path) @@which_git = path end
        self.which_git = `which git`

        def initialize(attrs = {})
          assign attrs

          assign_directories
          assign_git
          assign_string
          assign_worker
        end

        def new?
          schedule {
            path = File.join @git_dir, 'refs', 'heads'
            entries = Dir.entries(path) - %w[ . .. ]

            entries.size == 0
          }
        end

        # Tries to schedule an operation.
        def method_missing(op_sym, *args, &callback)
          schedule Operations.new(op_sym, *args, &callback)
        end

        # Schedules operation or proc for execution.
        def schedule(op = nil, &block)
          @worker.enq block || op, self
        end

        def inspect
          @git_dir
        end

        ### Convenience

        def remotes
          @remotes
        end
        def origin
          @remotes['origin']
        end
        # Returns collection of commits for current branch.
        def commits(path = '.')
          @branches.current.commits path
        end
        # Returns head for current branch. This is a moving target.
        def head
          @branches.current.head
        end

        protected

          def assign(attrs)
            attrs.each { |k, v| instance_variable_set :"@#{ k }", v }
          end
          def assign_directories
            @work_tree ||= ENV['GIT_WORK_TREE'] || Dir.getwd
            @work_tree = File.expand_path @work_tree

            @bare = @work_tree[-4..-1] == '.git' unless defined? @bare

            @git_dir ||= ENV['GIT_DIR']
            @git_dir ||= @bare ? @work_tree : File.join(@work_tree, '.git')
            @git_dir = File.expand_path @git_dir
          end
          def assign_git
            @which_git ||= @@which_git
            @which_git.strip!

            raise V::ECMDNOFO, 'git' if @which_git.empty?

            @branches = Branches.new self
            @index = Index.new self
          end
          def assign_string
            args = ["--no-pager"]
            args.push @bare ? "--bare" : "--work-tree='#{ @work_tree }'"
            args << "--git-dir='#{ @git_dir }'"

            @to_s = "#{ @which_git } #{ args * ' ' }"
          end
          def assign_worker
            @worker = Worker.new(@git_dir)
          end

      end
    end
  end
end
