# frozen_string_literal: true

require "spec_helper"

RSpec.describe Initable do
  context "with private scope" do
    subject(:initable) { Class.new.include(described_class[[:key, :one, 1]]).new }

    it "prevents private access" do
      expectation = proc { initable.one }
      expect(&expectation).to raise_error(NoMethodError, /private method 'one'/)
    end
  end

  context "with protected scope" do
    subject(:initable) { Class.new.include(described_class.protected([:key, :one, 1])).new }

    it "prevents private access" do
      expectation = proc { initable.one }
      expect(&expectation).to raise_error(NoMethodError, /protected method 'one'/)
    end
  end

  context "with public scope" do
    subject(:initable) { Class.new.include(described_class.public([:key, :one, 1])).new }

    it "allows public access" do
      expect(initable.one).to eq(1)
    end
  end
end
