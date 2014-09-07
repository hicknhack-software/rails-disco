require_relative '../../spec_helper'

describe ActiveEvent::Support::AttrInitializer do
  class RgbColor
    include ActiveEvent::Support::AttrInitializer
    attributes :r, :g, :b
  end

  describe 'constructor' do
    it 'works for no args' do
      expect(RgbColor.new).to be
    end

    it 'works for defined attributes' do
      expect(RgbColor.new r: 10, g: 20).to be
    end

    it 'fails for undeclared attributes' do
      expect { RgbColor.new z: 10 }.to raise_error(ActiveEvent::Support::UnknownAttributeError)
    end

    it 'fails for unauthorized hash' do
      class CheckedHash < Hash
        def permitted?
          false
        end
      end
      expect { RgbColor.new(CheckedHash.new.merge! r: 1) }.to raise_error(ActiveEvent::Support::ForbiddenAttributesError)
    end
  end

  describe 'instance' do
    before :all do
      @color = RgbColor.new r: 10, g: 20
    end

    it 'can retrieve attributes' do
      expect(@color.r).to eq(10)
      expect(@color.g).to eq(20)
      expect(@color.b).to be_nil
    end

    it 'can filter attributes' do
      expect(@color.attributes_except(:r)).to eq(g: 20)
    end

    it 'can convert to hash' do
      expect(@color.to_hash).to eq(r: 10, g: 20)
    end

    it 'is read only' do
      expect { @color.r = 20 }.to raise_error
    end
  end
end
