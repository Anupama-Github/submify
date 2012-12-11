class TopicUserRelationship < ActiveRecord::Base
  attr_accessible :topic_id, :user_id
  belongs_to :topic, class_name: "Topic"
  belongs_to :user, class_name: "User"

  validates :user_id, presence: true
  validates :topic_id, presence: true
end