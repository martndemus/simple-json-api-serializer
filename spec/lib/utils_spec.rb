require 'spec_helper'
require 'json_api/utils'

RSpec.describe JSONApi::Utils do
  describe ".canonicalize_id" do
    it "is a string" do
      expect(JSONApi::Utils.canonicalize_id('foo')).to eq 'foo'
    end

    it "is empty string for nil" do
      expect(JSONApi::Utils.canonicalize_id(nil)).to eq ''
    end

    it "forces other types to string" do
      expect(JSONApi::Utils.canonicalize_id(1)).to eq '1'
    end
  end

  describe ".canonicalize_type_name" do
    it "removes module names" do
      expect(JSONApi::Utils.canonicalize_type_name('Struct::Ducks')).to eq 'ducks'
    end

    it "downcases class names" do
      expect(JSONApi::Utils.canonicalize_type_name('Ducks')).to eq 'ducks'
    end

    it "pluralizes the type name" do
      expect(JSONApi::Utils.canonicalize_type_name('duck')).to eq 'ducks'
    end

    it "dasherizes multi word type names" do
      expect(JSONApi::Utils.canonicalize_type_name('MightyDucks')).to eq 'mighty-ducks'
    end
  end

  describe ".canonicalize_attribute_name" do
    it "hypenates multi word attribute names" do
      expect(JSONApi::Utils.canonicalize_attribute_name('mighty_ducks')).to eq 'mighty-ducks'
    end
  end
end
