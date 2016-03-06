class Head < Netzke::Base

  client_styles do |c|
    c.require :main
  end

  def configure(c)
    super

    c.html  = '<div class="head"><a class="head" href="/">CloudPort</a></div>'
    c.header = false
    c.region = :north
    c.height = 100
  end

end
