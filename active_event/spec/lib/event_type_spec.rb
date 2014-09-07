require_relative '../spec_helper'

describe ActiveEvent::EventType do
  class RgbColorEvent
    include ActiveEvent::EventType
    attributes :r, :g, :b
  end

  describe 'create instance' do
    it 'can create an instance' do
      expect(ActiveEvent::EventType.create_instance :RgbColorEvent, r: 10).to be
    end

    it 'can create events of any kind' do
      expect(ActiveEvent::EventType.create_instance :RandomEvent, r: 10).to be
    end
  end

  describe 'regular instance' do
    before :all do
      @color = RgbColorEvent.new r: 10, g: 20, b: 30
    end

    it 'can report type' do
      expect(@color.event_type).to eq('RgbColorEvent')
    end
  end

  describe 'unknown instance' do
    before :all do
      @random = ActiveEvent::EventType.create_instance :RandomEvent, r: 10
    end

    it 'can report type' do
      expect(@random.event_type).to eq('RandomEvent')
    end
  end
end
