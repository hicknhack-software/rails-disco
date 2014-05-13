require 'factory_girl'

FactoryGirl.define do
  factory :event, class: ActiveEvent::Event do
    event 'TestEvent'
    data name: 'Hello', r: 10, g: 20, b: 30
    created_at DateTime.new(2012, 12, 24, 11, 11, 11)
  end
end
