require 'test_helper'

def random_ip
  a = []

  4.times.each { a << (1+rand(254)).to_s }

  a.join('.')
end

class FailoverRuleTest < ActiveSupport::TestCase
  test "destination port is HTTPS" do
    assert_equal 443, FailoverRule::DESTINATION_PORT
  end

  test "redirect port is SSH" do
    assert_equal 22, FailoverRule::REDIRECT_PORT
  end

  test "iptables works with NAT table" do
    assert_match /-t nat\z/, FailoverRule::IPTABLES
  end

  test "iptables uses 'PREROUTING' chain" do
    assert_equal 'PREROUTING', FailoverRule::IPTABLES_CHAIN
  end

  test "non-zero number of saved records already exists" do
    refute_empty FailoverRule.all
  end

  test "every failover rule has a corresponding container" do
    FailoverRule.all.each do |t|
      assert_respond_to t, :container

      assert_instance_of Container, t.container
    end
  end

  test "it is possible to save a valid record" do
    t = FailoverRule.new

    t.container         = Container.first
    t.source_ip_address = random_ip

    assert t.save, t.errors.messages
  end

  test "it is NOT possible to save an invalid record" do
    t = FailoverRule.new

    t.source_ip_address = random_ip

    refute t.save, t.errors.messages

    t.container         = Container.first
    t.source_ip_address = '301.201.101.1' # mierda!

    refute t.save, t.errors.messages
  end

  test "created failover rule has valid redirect destination" do
    t = FailoverRule.new

    t.container         = Container.last
    t.source_ip_address = random_ip

    t.save

    assert_match /:22\z/, t.redirect_to
  end

  test 'iptables command changes according to passed action' do
    t = FailoverRule.create(
      source_ip_address: random_ip,
      container:         Container.last
    )

    assert_match /-A PREROUTING -s #{t.source_ip_address} -p tcp --dport 443 -j DNAT --to #{t.redirect_to}\z/,
      t.iptables_command(:add)

    assert_match /--line-numbers -nL PREROUTING | egrep \"#{t.nat_rule_match}\" | cut -f 1 -d ' ' | xargs -i .* -D PREROUTING '{}'\z/,
      t.iptables_command(:remove)

    assert_match /-nL PREROUTING | egrep \"#{t.nat_rule_match}\z/,
      t.iptables_command(:list)
  end

  test "nat rule match handles source IP previous value" do
    t = FailoverRule.new

    ADDR1 = random_ip
    ADDR2 = random_ip

    t.container         = Container.last
    t.source_ip_address = ADDR1

    assert_equal " #{ADDR1} *0.0.0.0/0 *tcp dpt:", t.nat_rule_match

    t.save

    assert_equal " #{ADDR1} *0.0.0.0/0 *tcp dpt:", t.nat_rule_match

    t.source_ip_address = ADDR2

    assert_equal " (#{ADDR2}|#{ADDR1}) *0.0.0.0/0 *tcp dpt:", t.nat_rule_match
  end

  test "nat rule operability could be ensured" do
    t = FailoverRule.create(
      source_ip_address: random_ip,
      container:         Container.first
    )

    assert t.ensure!
  end
end
