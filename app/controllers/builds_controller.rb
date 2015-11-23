class BuildsController < ApplicationController

  def index
  @builds = Build.all
    respond_to do |format|
      format.json { render json: @builds }
      format.xml  { render xml:  @builds }
    end
  end

end
