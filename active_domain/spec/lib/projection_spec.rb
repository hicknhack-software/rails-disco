require_relative '../spec_helper'

describe ActiveDomain::Projection do
  it 'should register automatically' do
    expect(ActiveDomain::ProjectionRegistry).to receive(:register) do |arg|
      arg.name.to_sym.should eq :TestProjection
    end
    class TestProjection
      include ActiveDomain::Projection
    end
  end
end
