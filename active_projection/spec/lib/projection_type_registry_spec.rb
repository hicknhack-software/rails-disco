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

  it 'report projections' do
    ActiveProjection::ProjectionTypeRegistry.projections.count.should eq 1
  end
end
