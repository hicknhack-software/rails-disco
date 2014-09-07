require_relative '../../spec_helper'

describe ActiveEvent::Support::AttrSetter do
  class MutableRgbColor
    include ActiveEvent::Support::AttrSetter
    attributes :r, :g, :b
  end

  describe 'constructor' do
    it 'works for no args' do
      expect( MutableRgbColor.new ).to be
    end

    it 'works for defined attributes' do
      expect( MutableRgbColor.new r: 10, g: 20 ).to be
    end

    it 'fails for undeclared attributes' do
      expect { MutableRgbColor.new z: 10 }.to raise_error(ActiveEvent::Support::UnknownAttributeError)
    end

    it 'fails for unauthorized hash' do
      class CheckedHash < Hash
        def permitted?
          false
        end
      end
      expect { MutableRgbColor.new(CheckedHash.new.merge! r: 1) }.to raise_error(ActiveEvent::Support::ForbiddenAttributesError)
    end
  end

  describe 'instance' do
    before :all do
      @color = MutableRgbColor.new r: 10, g: 20
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

    it 'is not automatically frozen' do
      expect(@color.frozen?).to be_falsey
    end

    it 'allows write' do
      @color.r = 20
      expect(@color.r).to eq(20)
      @color.r = 10
    end
  end
end
