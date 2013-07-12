# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ProjectGallery::Application.initialize!

new_logger = Logger.new('log/exceptions.log')
new_logger.info('THIS IS A NEW EXCEPTION!')

ActiveRecord::Base.logger = new_logger