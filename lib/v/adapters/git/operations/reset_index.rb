module V::Adapters::Git
  module Operations
    ResetIndex = operation(:reset) do
      # 1.6.3.2
      arguments do |args|
        args.mixed
        args.soft
        args.hard
        args.merged
        args.quiet(:alias => true).q
        args.commit(:HEAD, :rude => true).c
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
