class Blog <  ActiveRecord::Base #DataMapper::Base
  # property :title,      :string
  # property :content,    :text
  # property :created_at, :datetime

  has_many :comments
end