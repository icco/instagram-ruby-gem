require File.expand_path("../../../spec_helper", __FILE__)

describe Instagram::Client do
  Instagram::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Instagram::Client.new(format: format, client_id: "CID", client_secret: "CS", access_token: "AT")
      end

      describe ".subscriptions" do
        before do
          stub_get("subscriptions.#{format}")
            .with(query: { client_id: @client.client_id, client_secret: @client.client_secret })
            .to_return(body: fixture("subscriptions.#{format}"), headers: { content_type: "application/#{format}; charset=utf-8" })
        end

        it "should get the correct resource" do
          @client.subscriptions
          expect(a_get("subscriptions.#{format}")
            .with(query: { client_id: @client.client_id, client_secret: @client.client_secret }))
            .to have_been_made
        end

        it "should return an array of subscriptions" do
          subscriptions = @client.subscriptions
          expect(subscriptions).to be_a Array
          expect(subscriptions.first.object).to eq("user")
        end
      end

      describe ".create_subscription" do
        before do
          stub_post("subscriptions.#{format}")
            .with(body: { object: "user", callback_url: "http://example.com/instagram/callback", aspect: "media", client_id: @client.client_id, client_secret: @client.client_secret })
            .to_return(body: fixture("subscription.#{format}"), headers: { content_type: "application/#{format}; charset=utf-8" })
        end

        it "should get the correct resource" do
          @client.create_subscription("user", callback_url: "http://example.com/instagram/callback")
          expect(a_post("subscriptions.#{format}")
            .with(body: { object: "user", callback_url: "http://example.com/instagram/callback", aspect: "media", client_id: @client.client_id, client_secret: @client.client_secret }))
            .to have_been_made
        end

        it "should return the new subscription when successful" do
          subscription = @client.create_subscription("user", callback_url: "http://example.com/instagram/callback")
          expect(subscription.object).to eq("user")
        end
      end

      describe ".delete_media_comment" do
        before do
          stub_delete("subscriptions.#{format}")
            .with(query: { object: "user", client_id: @client.client_id, client_secret: @client.client_secret })
            .to_return(body: fixture("subscription_deleted.#{format}"), headers: { content_type: "application/#{format}; charset=utf-8" })
        end

        it "should get the correct resource" do
          @client.delete_subscription(object: "user")
          expect(a_delete("subscriptions.#{format}")
            .with(query: { object: "user", client_id: @client.client_id, client_secret: @client.client_secret }))
            .to have_been_made
        end
      end

      describe ".validate_update" do
        subject { @client.validate_update(body, headers) }

        context "when calculated signature matches request signature" do
          let(:body) { { foo: "bar" }.to_json }
          let(:request_signature) { OpenSSL::HMAC.hexdigest("sha1", @client.client_secret, body) }
          let(:headers) { { "X-Hub-Signature" => request_signature } }

          it { expect(subject).to be_truthy }
        end

        context "when calculated signature does not match request signature" do
          let(:body) { { foo: "bar" }.to_json }
          let(:request_signature) { "going to fail" }
          let(:headers) { { "X-Hub-Signature" => request_signature } }

          it { expect(subject).to be_falsey }
        end
      end

      describe ".process_subscriptions" do
        context "without a callbacks block" do
          it "should raise an ArgumentError" do
            expect do
              @client.process_subscription(nil)
            end.to raise_error(ArgumentError)
          end
        end

        context "with a callbacks block and valid JSON" do
          before do
            @json = fixture("subscription_payload.json").read
          end

          it "should issue a callback to on_user_changed" do
            @client.process_subscription(@json) do |handler|
              handler.on_user_changed do |user_id, _payload|
                expect(user_id).to eq("1234")
              end
            end
          end

          it "should issue a callback to on_tag_changed" do
            @client.process_subscription(@json) do |handler|
              handler.on_tag_changed do |tag_name, _payload|
                expect(tag_name).to eq("nofilter")
              end
            end
          end

          it "should issue both callbacks in one block" do
            @client.process_subscription(@json) do |handler|
              handler.on_user_changed do |user_id, _payload|
                expect(user_id).to eq("1234")
              end

              handler.on_tag_changed do |tag_name, _payload|
                expect(tag_name).to eq("nofilter")
              end
            end
          end
        end
      end

      context "with a valid signature" do
        before do
          @json = fixture("subscription_payload.json").read
        end

        it "should not raise an Instagram::InvalidSignature error" do
          expect do
            @client.process_subscription(@json, signature: "f1dbe2b6184ac2131209c87bba8e0382d089a8a2") do |handler|
              # hi
            end
          end.not_to raise_error
        end
      end

      context "with an invalid signature" do
        before do
          @json = fixture("subscription_payload.json").read
        end

        it "should raise an Instagram::InvalidSignature error" do
          invalid_signatures = ["31337H4X0R", nil]
          invalid_signatures.each do |signature|
            expect do
              @client.process_subscription(@json, signature: signature) do |handler|
                # hi
              end
            end.to raise_error(Instagram::InvalidSignature)
          end
        end
      end
    end
  end
end
