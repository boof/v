module V::Adapters::Git
  module Operations
    InitializeRepository = operation(:init) do
      # 1.6.3.2
      arguments do |args|
        args.quiet.q
        args.bare
        args.template(nil)
        args.shared(:umask, false)
      end

      def run(environment)
        out, err = exec environment
        err.empty? or raise V::ERROR, err

        environment
      end

    end
  end
end
