module V
  module Adapters
    module Git
      VERSION = [0,0,4]

      # Builds Operations module.
      Operations = Operations.new __FILE__.gsub(/\.rb$/, '')

      module WorkTreeRequirement
        # Ensures all calls require a git dir and a work tree.
        def call(environment)
          raise V::ENOTREPO unless File.directory? environment.git_dir
          raise V::ENOTWTREE if environment.bare

          super environment
        end
      end

    end
  end
end

begin
  __dir__ = File.dirname __FILE__
  %w[ environment branches commits index object participation status ].
  each { |basename| require "#{ __dir__ }/git/#{ basename }" }
end
