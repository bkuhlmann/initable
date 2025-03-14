# frozen_string_literal: true

require "spec_helper"

RSpec.describe Initable do
  context "with private scope" do
    subject :initable do
      Class.new.include(described_class[[:key, :one, 1], two: 2]).new
    end

    it "defines private methods" do
      expect(initable.private_methods).to include(:one, :two)
    end

    it "prevents private access" do
      expectation = proc { initable.one }
      expect(&expectation).to raise_error(NoMethodError, /private method 'one'/)
    end
  end

  context "with protected scope" do
    subject(:initable) { Class.new.include(described_class.protected([:key, :one, 1], two: 2)).new }

    it "defines protected methods" do
      expect(initable.protected_methods).to include(:one, :two)
    end

    it "prevents private access" do
      expectation = proc { initable.one }
      expect(&expectation).to raise_error(NoMethodError, /protected method 'one'/)
    end
  end

  context "with public scope" do
    subject(:initable) { Class.new.include(described_class.public([:key, :one, 1], two: 2)).new }

    it "defines protected methods" do
      expect(initable.public_methods).to include(:one, :two)
    end

    it "allows public access" do
      expect(initable.one).to eq(1)
    end
  end
end
