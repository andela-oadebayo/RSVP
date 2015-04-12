class Event < ActiveRecord::Base
  belongs_to :organizers, class_name: "User"
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :attendances
  has_many :users, :through => :attendances

  ## Friendly URLs
  extend FriendlyId
  friendly_id :title, use: :slugged

  friendly_id :slug_candidates, use: :slugged
  def slug_candidates
    [
        :title,
        [:title, :location],
    ]
  end

  def all_tags=(names)
    self.tags = names.split(",").map do |t|
      Tag.where(name: t.strip).first_or_create!
    end
  end

  def all_tags
    tags.map(&:name).join(", ")
  end

  def self.tagged_with(name)
    Tag.find_by_name!(name).events
  end

  def self.tag_counts
    Tag.select("tags.name, count(taggings.tag_id) as count").join(:taggings).group("taggings.tag_id")
  end

  def self.even_owner(organizer_id)
    User.find_by id: organizer_id
  end

end
