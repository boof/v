module V::Adapters::Git
  module Operations
    PushReferencesToRemote = operation(:push) do
      # 1.6.3.2
      arguments do |args|
        args.all
        args.mirror
        args.tags
        args.dry_run
        args.porcelain
        args.receive_pack nil
        args.repository nil
        args.thin
        args.no_thin
        args.force.f
        args.verbose.v
      end

      def run(environment)
        exec environment
      end

    end
  end
end
