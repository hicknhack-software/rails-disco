require_relative '../spec_helper'
describe ActiveEvent::ReplayServer do
  class TestEvent
  end
  before :all do
    @server = ActiveEvent::ReplayServer.instance
    @event = TestEvent.new
  end

  it 'republishes an event' do
    date = DateTime.now.utc
    allow(@server).to receive(:resend_exchange).and_return(Object)
    expect(@server.resend_exchange).to receive(:publish).with('{"bla":"Test2"}',
                                                              type: 'TestEvent',
                                                              headers: {id: 0, created_at: date.to_s, replayed: true},
                                       )
    expect(@event).to receive(:event).and_return(@event.class.name)
    expect(@event).to receive(:data).and_return(bla: 'Test2')
    expect(@event).to receive(:id).and_return(0)
    expect(@event).to receive(:created_at).and_return(date.to_s)
    @server.republish(@event)
  end

  it 'starts and stop republishing events' do
    expect(ActiveEvent::EventRepository).to receive(:after_id).and_return([1, 2, 3, 4], [])
    expect(@server).to receive(:republish_events).once
    @server.start_republishing
  end

  it 'republish all found events' do
    @server.instance_variable_set(:@events, [1, 2, 3, 4])
    expect(Thread).to receive(:pass).exactly(4).times
    expect(@server).to receive(:next_event).exactly(4).times { @server.instance_variable_get(:@events).shift }
    expect(@server).to receive(:republish).exactly(4).times
    @server.republish_events
  end

  describe 'new_id?' do
    before :each do
      @server.instance_variable_set(:@last_id, 4)
    end

    it 'overrides id if smaller' do
      @server.queue << 1
      expect(@server.new_id?).to be_true
      expect(@server.instance_variable_get(:@last_id)).to eq 1
    end

    it 'does nothing if id is greater' do
      @server.queue << 5
      expect(@server.new_id?).to be_false
      expect(@server.instance_variable_get(:@last_id)).not_to eq 5
    end

    it 'does nothing if queue is empty' do
      @server.queue.clear
      expect(@server.new_id?).to be_false
    end
  end

  it 'can update start id while running' do
    expect(ActiveEvent::EventRepository).to receive(:after_id).with(1).and_return([2, 3, 4], [])
    expect(ActiveEvent::EventRepository).to receive(:after_id).with(2).and_return([3, 4])
    expect(@server).to receive(:next_event).exactly(3).times { @server.instance_variable_get(:@events).shift }
    expect(@server).to receive(:republish).exactly(3).times
    expect(Thread).to receive(:pass).exactly(3).times
    @server.instance_variable_set(:@last_id, 2)
    @server.queue << 1
    @server.start_republishing
  end
end
