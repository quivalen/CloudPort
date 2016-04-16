#
# Failover [NAT] rule is a mechanism that redirects traffic from particular client
# to the destination container via port 443 (HTTPS). It is invoked via FailoverAPI.
#
# export INVOKE_IPTABLES=yes - if you develop on Linux and want to test iptables "in da flash".
#
class FailoverRule < ActiveRecord::Base

  DESTINATION_PORT  = 443
  REDIRECT_PORT     = 22
  IPTABLES          = "#{CloudPort::Application.iptables} -t nat"
  IPTABLES_CHAIN    = 'PREROUTING'

  belongs_to :container

  before_save    :remove_nat_rule!
  after_save     :add_nat_rule!
  before_destroy :remove_nat_rule!

  validates :container_id,
    presence:     true,
    numericality: { only_integer: true }

  validates :source_ip_address,
    presence:   true,
    uniqueness: true,
    format:     { with: IP_ADDR_REGEX }

  # Where do we redirect traffic?
  #
  # return [String] redirect target for failover traffic (a.b.c.d:port)
  def redirect_to
    @redirect_to ||= "#{container.ip_address}:#{REDIRECT_PORT.to_s}"
  end

  # Construct and return iptables command for the specified action
  #
  # return [String] a full iptables command to be executed
  def iptables_command(action)
    case action.to_sym
    when :add
      "#{IPTABLES} -A #{IPTABLES_CHAIN} -s #{source_ip_address} -p tcp --dport #{DESTINATION_PORT} -j DNAT --to #{redirect_to}"
    when :remove
      "#{IPTABLES} --line-numbers -nL #{IPTABLES_CHAIN} | egrep \"#{nat_rule_match}\" | cut -f 1 -d ' ' | xargs -i #{IPTABLES} -D #{IPTABLES_CHAIN} '{}'"
    when :list
      "#{IPTABLES} -nL #{IPTABLES_CHAIN} | egrep \"#{nat_rule_match}\""
    else
      fail("Unknown action: #{action}")
    end
  end

  # return [String] a match expression to grep failover NAT rules from iptables
  def nat_rule_match
    if source_ip_address == source_ip_address_was || !source_ip_address_was
      return " #{source_ip_address} *0.0.0.0/0 *tcp dpt:"
    end

    " (#{source_ip_address}|#{source_ip_address_was}) *0.0.0.0/0 *tcp dpt:"
  end

  # Ensure we have corresponding rule up and running! (always returns true or fails)
  def ensure!
    return true if nat_rule_exists?

    return true if add_nat_rule!

    fail('Failed to ensure failover rule operability!')
  end

  private

  def add_nat_rule!
    return true unless CloudPort::Application.invoke_iptables?

    system(iptables_command(:add))
  end

  def remove_nat_rule!
    return true unless CloudPort::Application.invoke_iptables?

    system(iptables_command(:remove))
  end

  def nat_rule_exists?
    return true unless CloudPort::Application.invoke_iptables?

    !!system(iptables_command(:list))
  end

end
