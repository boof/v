module V::Adapters::Git
  module Operations
    AddToIndex = operation(:add) do
      # 1.6.3.2
      arguments do |args|
        args.dry_run.n
        args.verbose.v
        args.force.f
        args.interactive.i
        args.patch.p
        args.edit.e
        args.all.A
        args.update.u
        args.intent_to_add.N
        args.refresh
        args.ignore_errors
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
