class BuildsController < ApplicationController

  def new
    @target_address = params[:target_address]
    @target_port    = params[:target_port]
  end

  def create
    @build = Build.new(
      target_address: params[:target_address],
      target_port:    params[:target_port],
    )

    if @build.save
      render text: @build.build_id
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  def show
    @build = Build.find_by_build_id(params[:id])

    unless @build
      render nothing: true, status: :not_found
    end
  end

  def download
    build     = Build.find_by_build_id(params[:id])
    file_name = params[:file_name]

    send_file(
      "#{build.binary_path}/#{file_name}",
      filename: file_name,
      type: 'application/octet-stream'
    )
  end

end
