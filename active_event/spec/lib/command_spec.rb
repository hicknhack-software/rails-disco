require_relative '../spec_helper'

describe ActiveEvent::Command do
  class TestCommand
    include ActiveEvent::Command
    attributes :r, :g, :b
  end

  describe 'create instance' do
    it 'can create an instance' do
      expect(TestCommand.new r: 10).to be
    end
  end
end
