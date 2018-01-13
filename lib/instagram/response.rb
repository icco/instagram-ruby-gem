module Instagram
  module Response
    def self.create(response_hash, ratelimit_hash)
      response_hash = {} unless response_hash
      data = begin
               raise if response_hash.data.nil?
               response_hash.data.dup
             rescue
               response_hash
             end
      data.extend(self)
      data.instance_exec do
        %w[pagination meta].each do |k|
          response_hash.public_send(k).tap do |v|
            instance_variable_set("@#{k}", v) if v
          end
        end
        @ratelimit = HashieWrapper.new(ratelimit_hash)
      end
      data
    end

    attr_reader :pagination
    attr_reader :meta
    attr_reader :ratelimit
  end
end
