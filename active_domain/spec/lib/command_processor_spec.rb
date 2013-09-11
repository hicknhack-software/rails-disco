require_relative '../spec_helper'

describe ActiveDomain::CommandProcessor do
  class TestDummy
  end
  class TestDummyProcessor
    include ActiveDomain::CommandProcessor

    process TestDummy do |cmd|
      event cmd
    end
  end

  describe 'class helper' do
    it 'define event process' do
      TestDummyProcessor.instance_method(:processTestDummy).should be
    end
  end

  describe 'instance' do
    it 'allows event method' do
      magic_number = 42
      expect(ActiveDomain::ProjectionRegistry).to receive(:invoke).with(magic_number)
      expect(ActiveDomain::EventRepository).to receive(:store).with(magic_number)
      expect(ActiveEvent::EventServer).to receive(:publish).with(magic_number)
      TestDummyProcessor.new.processTestDummy magic_number
    end
  end
end
