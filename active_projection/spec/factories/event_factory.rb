require 'factory_girl'

FactoryGirl.define do
  factory :projection, class: ActiveProjection::Projection do
    last_id 4
    solid true
  end
end
