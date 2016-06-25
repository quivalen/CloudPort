class ManageController < ApplicationController
  layout 'private'

  http_basic_authenticate_with(
    name:     'cloudport',
    password: lambda do
                file_name = '/deploy/password'
                return IO.read(file_name).split(%r{\n})[0].strip if File.exist?(file_name)
                'portcloud'
              end.call,
    realm:    'Web Admin UI'
  ) if Rails.env.production?

  def index
    render :inline => "<%= netzke :manage %>", layout: true
  end
end
