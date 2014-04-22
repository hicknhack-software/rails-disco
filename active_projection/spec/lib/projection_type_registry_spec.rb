require_relative '../spec_helper'

describe ActiveProjection::ProjectionTypeRegistry do
  class TestEvent
  end
  class TestProjection
  end
  before :all do
    ActiveProjection::ProjectionTypeRegistry.register(TestProjection)
  end

  it 'initializes' do
    ActiveProjection::ProjectionTypeRegistry.instance.should be
  end

  it 'invokes event handlers' do
    headers = {}
    event = TestEvent.new
    expect_any_instance_of(TestProjection).to receive(:evaluate).with(headers).and_return(true)
    expect_any_instance_of(TestProjection).to receive(:invoke).with(event, headers)
    ActiveProjection::ProjectionTypeRegistry.process(headers, event)
  end

  it 'synchronizes the known projections with the db' do
    expect(ActiveProjection::ProjectionRepository).to receive(:ensure_exists).with('TestProjection')
    ActiveProjection::ProjectionTypeRegistry.sync_projections
  end
end
