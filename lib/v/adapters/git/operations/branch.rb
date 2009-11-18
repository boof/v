module V::Adapters::Git
  module Operations
    Branch = operation(:branch) do
      # 1.6.3.2
      arguments do |args|
        args.color
        args.no_color
        args.remote(:alias => true).r
        args.all(:alias => true).a
        args.verbose.v
        args.abbrev(7)
        args.no_abbrev
        args.merged
        args.no_merged
        args.contains
        # <commit>
        args.track
        args.no_track
        args.reflog(:alias => true).l
        args.force(:alias => true).f
        # <branchname>
        # <startpoint>
        args.move(:alias => true).m
        args.move!(:alias => true).M
        # <oldbranch>
        # <newbranch>
        args.delete(:alias => true).d
        args.delete!(:alias => true).D
        # <branchname>
      end

      include WorkTreeRequirement
      def run(environment)
        out, err = exec environment
        err.empty? or raise V::ERROR, err

        out
      end

    end
  end
end
