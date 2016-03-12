class ManageController < ApplicationController
  layout 'private'

  http_basic_authenticate_with(
    name:     'cloudport',
    password: CloudPort::Application.web_admin_password,
    realm:    'Web Admin UI'
  ) if Rails.env.production?

  def index
    render :inline => "<%= netzke :manage %>", layout: true
  end

end
