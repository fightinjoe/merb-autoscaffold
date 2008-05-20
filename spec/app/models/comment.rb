class Comment < DataMapper::Base
  property :message,    :text
  property :created_at, :datetime

  belongs_to :blog
end