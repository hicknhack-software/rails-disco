require_relative '../spec_helper'
require_relative '../support/active_record'

describe ActiveProjection::ProjectionRepository do
  before :all do
    5.times do |i|
      FactoryGirl.create :projection, id: i, class_name: "TestProjection#{i}"
    end
  end
  describe 'create_or_get' do
    it 'creates a projection, if classname is not present' do
      expect(ActiveProjection::ProjectionRepository.create_or_get('TestProjection5').id).to eq 5
      expect(ActiveProjection::Projection.all.to_a.length).to eq 6
    end

    it 'does not create a projection, if classname is present' do
      expect(ActiveProjection::ProjectionRepository.create_or_get('TestProjection3').id).to eq 3
      expect(ActiveProjection::Projection.all.to_a.length).to eq 5
    end
  end
  describe 'broken' do
    it 'sets solid to false' do
      ActiveProjection::ProjectionRepository.set_broken 0
      expect(ActiveProjection::Projection.where(id:0).first.solid).to be_false
    end
  end
end
