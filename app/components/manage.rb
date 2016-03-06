class Manage < Netzke::Viewport::Base

  def configure(c)
    super

    c.layout = :border
    c.items  = [:head, :tunnels]
  end

 component :tunnels
 component :head

end
