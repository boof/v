module V
  module Adapters
    module Git
      class Commit < ObjectType

        # Completes :name in <tt>attrs</tt> and returns a Git::Object with
        # type :commit.
        def self.with(environment, attrs = {})
          if attrs[:name].length < 40
            glob = File.join environment.git_dir, 'objects',
                attrs[:name][0, 2], "#{ attrs[:name][2, 38] }*"

            attrs[:name] = attrs[:name][0, 2] + File.basename(Dir[ glob ].first)
          end

          Object.new environment, attrs.update(:type => :commit)
        end

        # see `git help show` for details
        F = {
          :commit_hash          => '%H',
          :commit_hash_abbrev   => '%h',
          :tree_hash            => '%T', #
          :tree_hash_abbrev     => '%t',
          :parent_hashes        => '%P', #
          :parent_hashes_abbrev => '%p',
          :a_name               => '%an', #
          :a_name_mailmap       => '%aN',
          :a_email              => '%ae', #
          :a_email_mailmap      => '%aE',
          :a_date               => '%ad',
          :a_date_rfc2822       => '%aD',
          :a_date_relative      => '%ar',
          :a_date_unix          => '%at', #
          :a_date_iso8601       => '%ai',
          :c_name               => '%cn', #
          :c_name_mailmap       => '%cN',
          :c_email              => '%ce', #
          :c_email_mailmap      => '%cE',
          :c_date               => '%cd',
          :c_date_rfc2822       => '%cD',
          :c_date_relative      => '%cr',
          :c_date_unix          => '%ct', #
          :c_date_iso8601       => '%ci',
          :ref_names            => '%d',
          :encoding             => '%e',
          :subject              => '%s', #
          :subject_sanitized    => '%f',
          :body                 => '%b', # extra
          :red                  => '%Cred',
          :green                => '%Cgreen',
          :blue                 => '%Cblue',
          :reset_color          => '%Creset',
          :newline              => '%n',
          :hex                  => '%%x%02x'
#                     o    %m: left, right or boundary mark
#                     o    %C(...): color specification, as described in color.branch.* config option
        }
        format = []
        format<< F[:tree_hash]
        format<< F[:parent_hashes]
        format<< F.values_at(:a_name, :a_email, :a_date_unix) * (F[:hex] % 0)
        format<< F.values_at(:c_name, :c_email, :c_date_unix) * (F[:hex] % 0)
        format<< F.values_at(:subject, :body) * (F[:hex] % 0)
        FORMAT = format * F[:newline]

        def content(object)
          object.environment.show object.name, :pretty => FORMAT
        end

        def tree(object)
          fetch object, :tree
        end
        def parents(object)
          fetch object, :parents
        end
        def author(object)
          fetch object, :author
        end
        def committer(object)
          fetch object, :commiter
        end
        def subject(object)
          fetch object, :subject
        end
        def body(object)
          fetch object, :body
        end

        def path(parent, *basenames)
          basenames.compact * '/'
        end

        protected

          def fetch(object, attribute)
            content = object.content.split "\n", 5
            env     = object.environment

            case attribute
            when :tree
              Tree.with env, :name => content[0], :parent => object
            when :parents
              content[1].split(' ').
              inject({}) { |mem, name| mem.update name => Commit.with(env, :name => name) }
            when :author
              Participation.new :author, *content[2].split("\0")
            when :commiter
              Participation.new :committer, *content[3].split("\0")
            when :subject
              content[4].split("\0").first
            when :body
              content[4].split("\0").last
            end
          end

        Object.register_type :commit => instance
        Object.register_methods :tree, :parents, :author, :committer,
            :subject, :body

      end
    end
  end
end
