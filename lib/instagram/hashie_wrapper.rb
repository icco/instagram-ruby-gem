require "hashie"

module Instagram
  # Custom hashie mash class so that it suppresses the log on warnings.
  class HashieWrapper < ::Hashie::Mash
    disable_warnings
  end
end
