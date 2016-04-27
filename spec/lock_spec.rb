require 'spec_helper'
require 'json'
require 'base64'

describe Diplomat::Lock do

  let(:faraday) { fake }
  let(:req) { fake }
  let(:session) { "fc5ca01a-c317-39ea-05e8-221da00d3a12" }
  let(:acl_token) { "f45cbd0b-5022-47ab-8640-4eaa7c1f40f1" }

  context "lock" do
    context "without an ACL token configured" do
      before { expect(faraday).to receive(:put).and_yield(req).and_return(OpenStruct.new({ body: "true", status: 200})) }
      before do
        Diplomat.configure do |c|
          c.acl_token = nil
        end
      end

      it "acquire" do
        expect(req).to receive(:url).with("/v1/kv/lock/key?acquire=#{session}")

        lock = Diplomat::Lock.new(faraday)

        expect(lock.acquire("lock/key", session)).to eq(true)
      end

      it "wait_to_acquire" do
        expect(req).to receive(:url).with("/v1/kv/lock/key?acquire=#{session}")

        lock = Diplomat::Lock.new(faraday)

        expect(lock.wait_to_acquire("lock/key", session, 2)).to eq(true)
      end

      it "release" do
        expect(req).to receive(:url).with("/v1/kv/lock/key?release=#{session}")

        lock = Diplomat::Lock.new(faraday)

        expect(lock.release("lock/key", session)).to eq("true")
      end
    end

    context "with an ACL token configured" do
      before { expect(faraday).to receive(:put).and_yield(req).and_return(OpenStruct.new({ body: "true", status: 200})) }
      before do
        Diplomat.configure do |c|
          c.acl_token = acl_token
        end
      end

      it "acquire" do
        expect(req).to receive(:url).with("/v1/kv/lock/key?acquire=#{session}&token=#{acl_token}")

        lock = Diplomat::Lock.new(faraday)

        expect(lock.acquire("lock/key", session)).to eq(true)
      end

      it "wait_to_acquire" do
        expect(req).to receive(:url).with("/v1/kv/lock/key?acquire=#{session}&token=#{acl_token}")

        lock = Diplomat::Lock.new(faraday)

        expect(lock.wait_to_acquire("lock/key", session, 2)).to eq(true)
      end

      it "release" do
        expect(req).to receive(:url).with("/v1/kv/lock/key?release=#{session}&token=#{acl_token}")

        lock = Diplomat::Lock.new(faraday)

        expect(lock.release("lock/key", session)).to eq("true")
      end
    end

  end

end
