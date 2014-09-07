require_relative '../spec_helper'
require_relative '../support/active_record'

describe ActiveProjection::ProjectionRepository do
  before :all do
    5.times do |i|
      FactoryGirl.create :projection, id: i, class_name: "TestProjection#{i}", last_id: 5 - i
    end
  end
  describe 'ensure_exists' do
    it 'creates a projection, if classname is not present' do
      expect(ActiveProjection::ProjectionRepository.ensure_exists('TestProjection5').id).to eq 5
      expect(ActiveProjection::Projection.all.to_a.length).to eq 6
    end

    it 'does not create a projection, if classname is present' do
      expect(ActiveProjection::ProjectionRepository.ensure_exists('TestProjection3').id).to eq 3
      expect(ActiveProjection::Projection.all.to_a.length).to eq 5
    end
  end
  describe 'broken' do
    it 'sets solid to false' do
      ActiveProjection::ProjectionRepository.mark_broken 0
      expect(ActiveProjection::Projection.where(id: 0).first.solid).to be_falsey
    end
  end
  it 'returns array of last ids' do
    expect(ActiveProjection::ProjectionRepository.last_ids).to eq [*1..5].reverse
  end
end
