require_relative '../spec_helper'

describe ActiveEvent::Domain do
  class TestDomain
    include ActiveEvent::Domain
  end

  describe 'connect and run command' do
    before :each do
      @command = Object.new
      @drb_object = double 'drb_object'
    end

    it 'sends command over instance' do
      expect(DRbObject).to receive(:new_with_uri).with(TestDomain.server_uri).and_return(@drb_object)
      expect(@drb_object).to receive(:run_command).with(@command)
      TestDomain.run_command(@command)
    end
  end
end
