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
    event = TestEvent.new
    expect_any_instance_of(TestProjection).to receive(:evaluate).with('test').and_return(true)
    expect_any_instance_of(TestProjection).to receive(:invoke).with(event)
    ActiveProjection::ProjectionTypeRegistry.process('test', event)
  end
end
