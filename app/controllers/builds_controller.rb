class BuildsController < ApplicationController

  def create
    name        = params[:name].strip
    target_host = "#{params[:target_host].strip}:#{params[:target_port]}"

    @build = Build.new(name: name, target_host: target_host)

    if @build.save
      render json: @build.build_id
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  def show
    @build = Build.find_by_build_id(params[:id])

    if @build
      render json: @build
    else
      render nothing: true, status: :not_found
    end
  end

end
