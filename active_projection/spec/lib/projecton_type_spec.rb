require_relative '../spec_helper'
require_relative '../support/active_record'

describe ActiveProjection::ProjectionType do
  it 'should register automatically' do
    expect(ActiveProjection::ProjectionTypeRegistry).to receive(:register) do |arg|
      arg.name.to_sym.should eq :DummyProjection
    end
    class DummyProjection
      include ActiveProjection::ProjectionType
    end
  end
  describe 'instance' do
    class TestProjection
      def test(event, headers)
      end

      def dummy(event)
      end
    end
    class TestEvent
    end
    before :each do
      allow(ActiveProjection::ProjectionTypeRegistry).to receive(:register)
      TestProjection.send(:include, ActiveProjection::ProjectionType)
      @projection = TestProjection.new
    end
    it 'initializes all handler' do
      handlers = @projection.instance_variable_get(:@handlers)
      handlers.length.should eq 2
      handlers['TestEvent'].should be
      handlers['DummyEvent'].should be
    end

    describe 'evaluate' do
      before :each do
        allow(@projection).to receive(:projection_id).and_return(0)
      end

      it 'rejects processing, if projection is broken' do
        expect(ActiveProjection::ProjectionRepository).to receive(:solid?).and_return(false)
        expect(ActiveProjection::ProjectionRepository).to_not receive(:get_last_id)
        @projection.evaluate({id: 1})
      end

      describe 'with solid projection' do
        before :each do
          allow(ActiveProjection::ProjectionRepository).to receive(:solid?).and_return(true)
          expect(ActiveProjection::ProjectionRepository).to receive(:get_last_id).and_return(5)
        end

        it 'processes event with the correct id' do
          expect(@projection.evaluate({id: 6})).to be_true
        end

        it 'rejects event with last id smaller event id' do
          expect(@projection.evaluate({id: 3})).to be_false
        end

        it 'rejects event with last greater equal event id' do
          expect(ActiveProjection::ProjectionRepository).to receive(:set_broken).with(0)
          expect(@projection.evaluate({id: 7})).to be_false
        end
      end
    end

    it 'invokes all handler' do
      expect(ActiveProjection::ProjectionRepository).to receive(:set_last_id).with(1, 6)
      expect(@projection).to receive(:test)
      expect(@projection).to_not receive(:dummy)
      @projection.invoke(TestEvent.new, {id: 6})
    end
  end
end