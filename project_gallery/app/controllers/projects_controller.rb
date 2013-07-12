class ProjectsController < ApplicationController
	def index
		@projects = Project.all
	end

	def show
		@project = Project.find(params[:id])
	end

	def new
		@project = Project.new
		3.times do
			@project.images.build
		end
	end

	def create
		@project = Project.new(params[:project])

		if @project.save

			respond_to do |format|
				format.html {redirect_to @project}
				format.json {}
			end
			
		else
			render 'new'
		end
	end

	def edit
		@project = Project.find(params[:id])
	end

	private
		def upload_image(image_io)
			extension = File.extname(image_io.original_filename)

			image_url = "/project_images/" + @project.id.to_s + extension

			File.open("public" + image_url, 'wb') do |file|
				file.write(image_io.read)
			end

			@project.update_attribute(:image_url, image_url)
		end
end
