require_relative '../spec_helper'

describe ActiveDomain::Projection do
  it 'should register automatically' do
    expect(ActiveDomain::ProjectionRegistry).to receive(:register) do |arg|
      expect(arg.name.to_sym).to eq(:TestProjection)
    end
    class TestProjection
      include ActiveDomain::Projection
    end
  end
end
