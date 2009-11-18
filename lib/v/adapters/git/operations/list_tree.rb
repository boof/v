module V::Adapters::Git
  module Operations
    ListTree = operation(:ls_tree) do
      # 1.6.3.2
      arguments do |args|
        # TODO: check naming
        args.directories(:alias => true).d
        args.recursive(:alias => true).r
        # TODO: check naming
        args.trace(:alias => true).t
        args.long.l
        args.zero(:alias => true).z
        args.name_only
        # TODO: implement support for non abbrev aliases
        args.name_status
        args.abbrev(40)
        args.full_name
        args.full_tree
      end

      def run(environment)
        out, err = exec environment
        err.empty? or raise V::ERROR, err

        out
      end

    end
  end
end
