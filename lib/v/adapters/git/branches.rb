module V
  module Adapters
    module Git

      # The head behaves like a commit.
      class Head
        instance_methods.each { |m| m =~ /^__/ or undef_method m }
        attr_reader :branch, :path

        def initialize(env, branch)
          @environment, @branch = env, branch
          @path = File.join env.git_dir, %W[ refs heads #{ branch } ]
        end

        # Returns the tip of the branch.
        def commit
          @environment.schedule do
            raise V::EUNREV unless File.readable? @path
            Commit.with @environment, :name => File.read(@path).chomp
          end
        end

        # Delegates to commit.
        def method_missing(meth, *args, &block)
          commit.send meth, *args, &block
        end

      end

      class Branch
        attr_reader :name
        alias_method :to_s, :name

        def initialize(environment, name)
          @environment, @name = environment, name
        end

        def create(*args)
          @environment.branch @name, *args
          return self
        end

        # Returns commits for this branch.
        def commits(path = '.')
          @commits ||= Commits.new @environment, self, path
        end
        # Returns head for this branch.
        def head
          @head ||= Head.new @environment, self
        end

        # Returns true if this branch has a startpoint, false otherwise.
        def exists?
          head.commit
        rescue V::EUNREV
          return false
        end

        # Returns the tip of this branch.
        def tip
          head.commit
        end

        def update(*args)
          @environment.branch @name, *args.dup << { :force => true }
          return self
        end
        def destroy(opts = {})
          arguments = {}
          arguments[ opts[:force] ? :D : :d ] = true
          arguments[:r] = true if opts[:remote]

          @environment.branch @name, arguments

          return self
        end

      end

      class Branches
        include Enumerable
        def initialize(environment)
          @environment = environment
          root = File.join environment.git_dir, %w[ refs heads ]
          @glob, @offset = File.join(root, %w[ ** * ]), root.length + 1
        end

        # Returns current branch.
        def current
          @environment.schedule do
            head = File.read File.join(@environment.git_dir, 'HEAD')
            name = head.split(':', 2).last.split('/', 3).last.strip

            Branch.new @environment, name
          end
        end


        # Returns the branch with the given <tt>name</tt>.
        def [](name)
          Branch.new @environment, name
        end

        # Yields instance of Branch for each branch found in refs/heads.
        def each
          @environment.schedule do
            Dir[ @glob ].each do |path|
              yield Branch.new(@environment, path[ @offset.. -1 ])
            end
          end
        end
      end
    end
  end
end
