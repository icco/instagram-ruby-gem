require "openssl"
require "base64"

module Instagram
  # Defines HTTP request methods
  module Request
    # Perform an HTTP GET request
    def get(path, options = {}, signature = false, raw = false, unformatted = false, no_response_wrapper = self.no_response_wrapper, signed = sign_requests)
      request(:get, path, options, signature, raw, unformatted, no_response_wrapper, signed)
    end

    # Perform an HTTP POST request
    def post(path, options = {}, signature = false, raw = false, unformatted = false, no_response_wrapper = self.no_response_wrapper, signed = sign_requests)
      request(:post, path, options, signature, raw, unformatted, no_response_wrapper, signed)
    end

    # Perform an HTTP PUT request
    def put(path, options = {}, signature = false, raw = false, unformatted = false, no_response_wrapper = self.no_response_wrapper, signed = sign_requests)
      request(:put, path, options, signature, raw, unformatted, no_response_wrapper, signed)
    end

    # Perform an HTTP DELETE request
    def delete(path, options = {}, signature = false, raw = false, unformatted = false, no_response_wrapper = self.no_response_wrapper, signed = sign_requests)
      request(:delete, path, options, signature, raw, unformatted, no_response_wrapper, signed)
    end

    private

    # Perform an HTTP request
    def request(method, path, options, signature = false, raw = false, unformatted = false, no_response_wrapper = false, signed = sign_requests)
      response = connection(raw).send(method) do |request|
        path = formatted_path(path) unless unformatted

        if signed == true
          sig_options = options.merge(client_id: client_id) unless client_id.nil?
          unless access_token.nil?
            sig_options = options.merge(access_token: access_token)
          end
          sig = generate_sig("/" + path, sig_options, client_secret)
          options[:sig] = sig
        end

        case method
        when :get, :delete
          request.url(URI.encode(path), options)
        when :post, :put
          request.path = URI.encode(path)
          request.body = options unless options.empty?
        end
        if signature && !client_ips.nil?
          request.headers["X-Insta-Forwarded-For"] = get_insta_fowarded_for(client_ips, client_secret)
        end
      end
      return response if raw
      return response.body if no_response_wrapper
      Response.create(response.body, limit: response.headers["x-ratelimit-limit"].to_i,
                                     remaining: response.headers["x-ratelimit-remaining"].to_i)
    end

    def formatted_path(path)
      [path, format].compact.join(".")
    end

    def get_insta_fowarded_for(ips, secret)
      digest = OpenSSL::Digest.new("sha256")
      signature = OpenSSL::HMAC.hexdigest(digest, secret, ips)
      [ips, signature].join("|")
    end

    def generate_sig(endpoint, params, secret)
      sig = endpoint
      params.sort.map do |key, val|
        sig += format("|%s=%s", key, val)
      end
      digest = OpenSSL::Digest.new("sha256")
      OpenSSL::HMAC.hexdigest(digest, secret, sig)
    end
  end
end
