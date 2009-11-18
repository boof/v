module V
  module Adapters
    module Git
      Participation = Struct.new(:role, :name, :email, :unix_timestamp) do

        def to_s
          "#{ role } #{ name } <#{ email }> #{ unix_timestamp }"
        end

        # TODO: take TZ into account
        def time
          Time.at unix_timestamp.to_i
        end

      end
    end
  end
end
