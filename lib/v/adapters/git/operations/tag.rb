module V::Adapters::Git
  module Operations
    Tag = operation(:tag) do
      # 1.6.3.2
      arguments do |args|
        args.annotated(:alias => true).a
        args.signed(:alias => true).s
        args.signed_as(nil, :alias => true).u
        args.force(:alias => true).f
        args.delete(:alias => true).d
        args.verify(:alias => true).v
        args.lines(1, :alias => true).n
        args.list('*', :alias => true).l
        args.contains.c
        args.message(nil, :alias => true).m
        args.file(nil, :alias => true).F
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
