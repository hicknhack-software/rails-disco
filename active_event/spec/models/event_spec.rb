require_relative '../spec_helper'
require_relative '../support/active_record'

describe ActiveEvent::EventRepository do
  describe 'instance' do
    before :all do
      5.times do |i|
        FactoryGirl.create :event, id: (5 - i)
      end
    end

    it 'gives all events ordered by event id' do
      ActiveEvent::EventRepository.ordered.map { |event| event.id }.should eq [*1..5]
    end

    it 'gives newer events' do
      ActiveEvent::EventRepository.after_id(3).map { |event| event.id }.should eq [4, 5]
    end
  end
end
