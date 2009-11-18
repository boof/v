module V::Adapters::Git
  module Operations
    ListFiles = operation(:ls_files) do
      # 1.6.3.2
      arguments do |args|
        args.zero(:alias => true).z
        args.tags(:alias => true).t
        # TODO: understand v option
        args.vulgar(:alias => true).v
        args.cached.c
        args.deleted.d
        args.others.o
        args.ignored.i
        args.stage.s
        args.unmerge.u
        args.killed.k
        args.modified.m
        args.exclude(nil).x
        args.exclude_from(nil).X
        args.exclude_per_directory(nil)
        args.exclude_standard
        args.error_unmatch
        args.with_tree(nil)
        args.full_name
        args.abbrev(40)
        args << '--'
      end

      def run(environment)
        out, err = exec environment
        err.empty? or raise V::ERROR, err

        out
      end

    end
  end
end
