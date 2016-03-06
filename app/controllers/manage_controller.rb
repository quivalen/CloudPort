class ManageController < ApplicationController
  layout 'private'

  def index
    render :inline => "<%= netzke :manage %>", layout: true
  end

end
