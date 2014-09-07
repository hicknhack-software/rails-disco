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
    expect(ActiveProjection::ProjectionTypeRegistry.instance).to be
  end

  it 'report projections' do
    expect(ActiveProjection::ProjectionTypeRegistry.projections.count).to eq(1)
  end
end
