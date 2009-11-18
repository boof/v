module V::Adapters::Git
  module Operations
    DiffIndex = operation(:diff_index) do
      # 1.6.3.2
      arguments do |args|
        # TODO: complete arguments ...
        args.cached
        args.name_status
      end

      def run(environment)
        out, err = exec environment
        err.empty? or raise V::ERROR, err

        out
      end

    end
  end
end
