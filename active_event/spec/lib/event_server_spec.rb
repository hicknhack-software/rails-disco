require_relative '../spec_helper'
describe ActiveEvent::EventServer do
  class TestEvent
  end
  before :all do
    @server = ActiveEvent::EventServer.instance
    @event = TestEvent.new
  end
  describe 'resend_events_after' do
    it 'starts the replay server if its not running' do
      expect(ActiveEvent::ReplayServer).to receive(:start)
      @server.resend_events_after(1).join
    end

    it 'updates the replay server if its running' do
      @server.instance_variable_set(:@replay_server_thread, Thread.new { sleep 1 })
      expect(ActiveEvent::ReplayServer).to receive(:update)
      @server.resend_events_after 1
    end
  end

  it 'publishes an event' do
    allow(@server).to receive(:event_exchange).and_return(Object)
    expect(@server.event_exchange).to receive(:publish).with('Test2', type: 'TestEvent', headers: 'Test')
    expect(@event).to receive(:store_infos).and_return('Test')
    expect(@event).to receive(:to_json).and_return('Test2')
    @server.class.publish(@event)
  end
end
