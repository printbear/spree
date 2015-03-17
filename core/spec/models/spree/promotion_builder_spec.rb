require 'spec_helper'

describe Spree::PromotionBuilder do
  let(:promotion) { build(:promotion) }
  let(:base_code) { 'abc' }
  let(:number_of_codes) { 1 }
  let(:promotion_attrs) { { name: 'some promo' } }
  let(:builder) { Spree::PromotionBuilder.new(promotion_attrs: promotion_attrs, base_code: base_code, number_of_codes: number_of_codes) }

  describe "#perform" do
    subject { builder.perform }

    context "with 1 or more codes" do
      it "builds promotion codes" do
        subject
        expect(builder.promotion.codes.length).to eq number_of_codes
      end
    end

    context "with 0 codes specified" do
      let(:number_of_codes) { 0 }

      it "builds promotion codes" do
        subject
        expect(builder.promotion.codes.length).to eq number_of_codes
      end
    end

    it "saves the promotion" do
      subject
      expect(builder.promotion).to be_persisted
    end

    it "returns true on success" do
      expect(subject).to be_truthy
    end
  end

  describe "#build_promotion_codes" do
    context "when number_of_codes is 1" do
      subject { builder.build_promotion_codes }

      it "builds one code" do
        subject
        expect(builder.promotion.codes.size).to eq 1
      end

      it "builds one code with the correct value" do
        subject
        expect(builder.promotion.codes.map(&:value)).to eq ['abc']
      end
    end

    context "when number_of_codes is greater than 1" do
      subject { builder.build_promotion_codes }
      before  { srand 123 }
      let(:number_of_codes) { 2 }

      it "builds the correct number of codes" do
        subject
        expect(builder.promotion.codes.size).to eq 2
      end

      it "builds codes with distinct values" do
        subject
        expect(builder.promotion.codes.map(&:value).uniq.size).to eq 2
      end

      it "builds codes with the same base prefix" do
        subject
        expect(builder.promotion.codes.map(&:value)).to match_array(["abc_NCCGRT", "abc_KZWBAR"])
      end

      context "there is a collision with the random codes generated" do
        before { Spree::PromotionBuilder.default_random_code_length = 1 }
        let(:number_of_codes) { 26 }

        # With a random code length of 1, collisions happen frequently.
        # with srand(123) it happens after the third iteration. Given a different random seed,
        # we have a 6.5510660712837325e-09 percent chance of it not colliding with 26 iterations.
        it "will resolve the collision" do
          subject
          expect(builder.promotion.codes.map(&:value).uniq.size).to eq number_of_codes
        end
      end
    end
  end

  describe "#error_messages" do
    let(:promotion_attrs) { {} }
    subject { builder.error_messages }
    before { builder.perform }

    it "returns the promotion's errors" do
      expect(subject).to eq "Name can't be blank"
    end
  end

  describe "#success_messages" do
    subject { builder.success_messages }
    before { builder.perform }

    it "returns 'Promotion has been successfully created!'" do
      expect(subject).to eq "Promotion has been successfully created!"
    end
  end
end
