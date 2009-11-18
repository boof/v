module V
  module Adapters
    module Git
      Status = Struct.new :diff do

        ADDED         = :A
        COPIED        = :C
        DELETED       = :D
        MODIFIED      = :M
        RENAMED       = :R
        TYPE_CHANGED  = :T
        UNMERGED      = :U
        UNKNOWN       = :X

        def added?(filename)
          index[filename] == ADDED
        end
        def copied?(filename)
          index[filename] == COPIED
        end
        def deleted?(filename)
          index[filename] == DELETED
        end
        def modified?(filename)
          index[filename] == MODIFIED
        end
        def renamed?(filename)
          index[filename] == RENAMED
        end
        def type_changed?(filename)
          index[filename] == TYPE_CHANGED
        end
        def unmerged?(filename)
          index[filename] == UNMERGED
        end
        def unknown?(filename)
          index[filename] == UNKNOWN
        end

        def [](filename)
          index[filename]
        end

        protected

          def index
            build_index unless defined? @index
            @index
          end
          def build_index
            @index = diff.split($/).inject({}) do |mem, line|
              state, path = line.split("\t").map { |v| v.strip }
              mem.update path => state.to_sym
            end
          end

      end
    end
  end
end
