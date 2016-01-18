class BuildsController < ApplicationController

  def index
    @operating_systems        = hash_to_options_for_select(Build.operating_systems)
    @default_operating_system = Build::Defaults.operating_system

    @cpu_architectures        = hash_to_options_for_select(Build.cpu_architectures.each)
    @default_cpu_architecture = Build::Defaults.cpu_architecture
  end

  def new
    @target_address   = params[:target_address]
    @target_port      = params[:target_port]
    @operating_system = params[:operating_system]
    @cpu_architecture = params[:cpu_architecture]
  end

  def create
    @build = Build.new(
      target_address:   params[:target_address],
      target_port:      params[:target_port],
      operating_system: params[:operating_system],
      cpu_architecture: params[:cpu_architecture],
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

  private

  def hash_to_options_for_select(hash)
    options = []
    hash.each { |id, name| options << [name, id.to_s] }
    options
  end

end
