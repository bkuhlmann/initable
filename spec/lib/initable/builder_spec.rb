# frozen_string_literal: true

require "spec_helper"

RSpec.describe Initable::Builder do
  subject(:builder) { implementation.new(1, 2, 3, four: 4, five: 5, a: 1, &function) }

  let(:function) { proc { "test" } }
  let(:implementation) { Class.new.include(described_class.new(*parameters)) }

  let :parameters do
    [
      %i[req one],
      [:opt, :two, 2],
      %i[rest three],
      %i[keyreq four],
      [:key, :five, 5],
      %i[keyrest six],
      %i[block seven]
    ]
  end

  describe "#initialize" do
    it "defines instance variables" do
      expect(builder.inspect).to include(
        "@one=1, @two=2, @three=[3], @four=4, @five=5, @six={a: 1}, @seven=#{function}"
      )
    end

    it "doesn't define public readers for attributes" do
      expect(builder.inspect).to have_attributes({})
    end

    context "with required positional inheritance" do
      let(:implementation) { Class.new.include described_class.new(%i[req one]) }

      it "defines instance variable" do
        expect(implementation.new(1).inspect).to include("@one=1")
      end

      it "defines additional variable" do
        implementation.include described_class.new(%i[req two])
        expect(implementation.new(1, 2).inspect).to include("@one=1, @two=2")
      end
    end

    context "with optional positional inheritance" do
      let(:implementation) { Class.new.include described_class.new([:opt, :one, 1]) }

      it "defines instance variable with default value" do
        expect(implementation.new.inspect).to include("@one=1")
      end

      it "defines instance variable with custom value" do
        expect(implementation.new(10).inspect).to include("@one=10")
      end

      it "overrides instance variable" do
        implementation.include described_class.new([:opt, :one, 10])
        expect(implementation.new.inspect).to include("@one=10")
      end

      it "defines additional variable" do
        implementation.include described_class.new([:opt, :one, 1], [:opt, :two, 2])
        expect(implementation.new.inspect).to include("@one=1, @two=2")
      end
    end

    context "with single splat positional inheritance" do
      let(:implementation) { Class.new.include described_class.new(%i[rest test]) }

      it "defines instance variable with original namme" do
        expect(implementation.new(1, 2, 3).inspect).to include("@test=[1, 2, 3]")
      end

      it "defines instance variable with anonymous name" do
        implementation.include described_class.new([:rest])
        expect(implementation.new(1, 2, 3).inspect).to include("@test=[1, 2, 3]")
      end

      it "defines instance variables with alternate name" do
        implementation.include described_class.new(%i[rest alt])
        expect(implementation.new(1, 2, 3).inspect).to include("@test=[1, 2, 3], @alt=[1, 2, 3]")
      end
    end

    context "with required keyword inheritance" do
      let(:implementation) { Class.new.include described_class.new(%i[keyreq one]) }

      it "defines instance variable" do
        expect(implementation.new(one: 1).inspect).to include("@one=1")
      end

      it "defines additional variable" do
        implementation.include described_class.new(%i[keyreq two])
        expect(implementation.new(one: 1, two: 2).inspect).to include("@one=1, @two=2")
      end
    end

    context "with optional keyword inheritance" do
      let(:implementation) { Class.new.include described_class.new([:key, :one, 1]) }

      it "defines instance variable with default value" do
        expect(implementation.new.inspect).to include("@one=1")
      end

      it "defines instance variable with custom value" do
        expect(implementation.new(one: 10).inspect).to include("@one=10")
      end

      it "overrides instance variable" do
        implementation.include described_class.new([:key, :one, 10])
        expect(implementation.new.inspect).to include("@one=10")
      end

      it "defines additional variable" do
        implementation.include described_class.new([:key, :two, 2])
        expect(implementation.new.inspect).to include("@one=1, @two=2")
      end
    end

    context "with double splat keyword inheritance" do
      let(:implementation) { Class.new.include described_class.new(%i[keyrest test]) }

      it "defines instance variable with original namme" do
        expect(implementation.new(a: 1, b: 2).inspect).to include("@test={a: 1, b: 2}")
      end

      it "defines instance variable with anonymous name" do
        implementation.include described_class.new([:keyrest])
        expect(implementation.new(a: 1, b: 2).inspect).to include("@test={a: 1, b: 2}")
      end

      it "defines instance variables with alternate name" do
        implementation.include described_class.new(%i[keyrest alt])

        expect(implementation.new(a: 1, b: 2).inspect).to include(
          "@test={a: 1, b: 2}, @alt={a: 1, b: 2}"
        )
      end
    end

    context "with block inheritance" do
      let(:implementation) { Class.new.include described_class.new(%i[block test]) }

      it "defines instance variable with default value" do
        expect(implementation.new.inspect).to include("@test=nil")
      end

      it "defines instance variable with custom value" do
        expect(implementation.new(&function).inspect).to include("@test=#{function}")
      end

      it "defines additional variable" do
        implementation.include described_class.new(%i[block alt])

        expect(implementation.new(&function).inspect).to include(
          "@test=#{function}, @alt=#{function}"
        )
      end
    end

    context "with inheritance" do
      subject(:builder) { implementation.new(1, 2, :sub, 3, four: 4, five: 5, a: 1, &function) }

      let :sub_parameters do
        [
          %i[opt sub sub]
        ]
      end

      it "defines instance variables for subclass" do
        implementation.include described_class.new(*sub_parameters)

        expect(builder.inspect).to include(
          "@one=1, @two=2, @three=[3], @four=4, @five=5, @six={a: 1}, " \
          "@seven=#{function}, @sub=:sub"
        )
      end
    end

    context "with private attributes" do
      let(:implementation) { Class.new.include(described_class.new(*parameters, scope: :private)) }

      it "defines instance variables" do
        expect(builder.inspect).to include(
          "@one=1, @two=2, @three=[3], @four=4, @five=5, @six={a: 1}, @seven=#{function}"
        )
      end

      it "defines private methods" do
        expect(builder.private_methods).to include(:one, :two, :three, :four, :five, :six, :seven)
      end

      it "answers no attributes" do
        expect(builder).to have_attributes({})
      end
    end

    context "with public attributes" do
      let(:implementation) { Class.new.include(described_class.new(*parameters, scope: :public)) }

      it "defines instance variables" do
        expect(builder.inspect).to include(
          "@one=1, @two=2, @three=[3], @four=4, @five=5, @six={a: 1}, @seven=#{function}"
        )
      end

      it "defines public methods" do
        expect(builder.public_methods).to include(:one, :two, :three, :four, :five, :six, :seven)
      end

      it "answers public attributes" do
        expect(builder).to have_attributes(
          one: 1,
          two: 2,
          three: [3],
          four: 4,
          five: 5,
          six: {a: 1},
          seven: function
        )
      end
    end

    context "with protected attributes" do
      let :implementation do
        Class.new.include(described_class.new(*parameters, scope: :protected))
      end

      it "defines instance variables" do
        expect(builder.inspect).to include(
          "@one=1, @two=2, @three=[3], @four=4, @five=5, @six={a: 1}, @seven=#{function}"
        )
      end

      it "defines protected methods" do
        expect(builder.protected_methods).to contain_exactly(
          :one,
          :two,
          :three,
          :four,
          :five,
          :six,
          :seven
        )
      end

      it "answers no attributes" do
        expect(builder).to have_attributes({})
      end
    end

    context "with invalid scope" do
      let(:implementation) { Class.new.include(described_class.new(*parameters, scope: :bogus)) }

      it "defines instance variables" do
        expect(builder.inspect).to include(
          "@one=1, @two=2, @three=[3], @four=4, @five=5, @six={a: 1}, @seven=#{function}"
        )
      end

      it "defines no methods" do
        expect(builder.public_methods).not_to include(
          :one,
          :two,
          :three,
          :four,
          :five,
          :six,
          :seven
        )
      end

      it "answers no attributes" do
        expect(builder).to have_attributes({})
      end
    end
  end
end
