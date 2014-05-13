require_relative '../spec_helper'

describe ActiveDomain::ProjectionRegistry do
  class TestEvent
  end
  class TestProjection
    def test_event(event)
    end

    def dummy_event(event)
    end
  end
  before :all do
    ActiveDomain::ProjectionRegistry.register(TestProjection)
  end

  it 'initializes' do
    ActiveDomain::ProjectionRegistry.instance.should be
  end

  it 'invokes event handlers' do
    event = TestEvent.new
    expect_any_instance_of(TestProjection).to receive(:test_event).with(event)
    ActiveDomain::ProjectionRegistry.invoke(event)
  end
end
