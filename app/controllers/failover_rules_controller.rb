class FailoverRulesController < ApplicationController

  protect_from_forgery with: :null_session

  def create
    @container = find_container

    unless @container
      render json: 'Unable to lookup container', status: :not_found
      return
    end

    @failover_rule            = find_failover_rule || new_failover_rule
    @failover_rule.container  = @container

    if @failover_rule.save
      render json: { source_ip_address: @failover_rule.source_ip_address }, status: :ok
    else
      render json: @failover_rule.errors, status: :unprocessable_entity
    end
  end

  private

  def find_container
    build = Build.find_by_ptu_build_id(params[:id])

    return nil unless build

    container = build.container
  end

  def find_failover_rule
    FailoverRule.find_by(source_ip_address: request.remote_ip)
  end

  def new_failover_rule
    FailoverRule.new(source_ip_address: request.remote_ip)
  end

end
