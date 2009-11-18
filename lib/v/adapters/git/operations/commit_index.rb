module V::Adapters::Git
  module Operations
    CommitIndex = operation(:commit) do
      # 1.6.3.2
      arguments do |args|
        args.all.a
        args.interactive
        args.signoff.s
        args.verbose.v
        args.untracked_files(:all).u
        args.amend
        args.reedit_message(nil).c
        args.reuse_message(nil).C
        args.file(nil).F
        args.message(nil, :first => true).m
        args.allow_empty
        args.no_verify.n
        args.edit.e
        args.author nil
        args.cleanup :default
        args << '--'
        args.include.i
        args.only.o
      end

      include WorkTreeRequirement
      def run(environment)
        out, err = exec environment
        err.empty? or raise V::ERROR, err

        name = /^\[(?:.*) (\S+)\]/.match(out).captures.first
        Commit.with environment, :name => name
      rescue
        return out
      end

    end
  end
end
