module V::Adapters::Git
  module Operations
    ShowObject = operation(:show) do
      # 1.6.3.2
      arguments do |args|
        args.pretty(:medium)
        args.abbrev_commit
        args.oneline
        args.encoding('UTF-8')
      end

      def run(environment)
        out, err = exec environment
        err.empty? or raise V::ERROR, err

        out
      end

    end
  end
end
