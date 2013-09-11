require_relative '../spec_helper'
describe ActiveEvent::EventServer do
  class TestEvent
  end
  before :all do
    @server = ActiveEvent::EventServer.instance
    @event = TestEvent.new
  end
  it 'resends requests' do
    allow(@event).to receive(:event)
    allow(@event).to receive(:id)
    allow(@event).to receive(:data).and_return({})
    expect(ActiveEvent::EventType).to receive(:create_instance).twice.and_return(Object)
    expect(Object).to receive(:add_store_infos).twice
    expect(ActiveEvent::EventRepository).to receive(:after_id).and_return([@event, @event])
    expect(@server.class).to receive(:publish).twice
    @server.class.resend_events_after 1
  end

  it 'publishes an event' do
    allow(@server).to receive(:event_exchange).and_return(Object)
    expect(@server.event_exchange).to receive(:publish).with("Test2", {:type => "TestEvent", :headers => "Test"})
    expect(@event).to receive(:store_infos).and_return('Test')
    expect(@event).to receive(:to_json).and_return('Test2')
    @server.class.publish(@event)
  end
end
