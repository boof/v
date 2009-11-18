module V::Adapters::Git
  module Operations
    RemoveFromIndex = operation(:rm) do
      # 1.6.3.2
      arguments do |args|
        args.force.f
        args.dry_run.n
        args.recursive(:alias => true).r
        args.cached
        args.ignore_unmatch
        args.quiet.q
        args << '--'
      end

      include WorkTreeRequirement
      def run(environment)
        out, err = exec environment
        err.empty? or raise V::ERROR, err

        Index.new environment
      end

    end
  end
end
