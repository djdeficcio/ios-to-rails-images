class Project < ActiveRecord::Base
  attr_accessible :framework, :name, :images_attributes

  has_many :images, class_name: 'ProjectImage', dependent: :destroy

  accepts_nested_attributes_for :images
end
