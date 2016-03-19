class Tunnels < Netzke::Grid::Base

  client_styles do |c|
    c.require :main
    c.require :state
  end

  action :delete do |a|
    super a
    a.text = 'Destroy tunnel!'
    a.icon = :cross
  end

  def last_connected_at(connections)
    return '-' if connections.empty?

    connections.map { |c| c.connected_at }.sort.last
  end

  def connection_state(container)
    d = !container.connections.direct.empty?
    f = !container.connections.forwarded.empty?

    return :conn if d && f
    return :wait if d && !f
    return :mess if !d && f

    :none
  end

  def direct_remote(remote)
    return '-' unless remote

    remote
  end

  def forwarded_remotes(remotes)
    return '' unless remotes

    return remotes.sort.join(' ')
  end

  def configure(c)
    super

    c.title  = '<b>Tunnels</b>'
    c.model  = 'Build'
    c.region = :center

    c.edit_inline   = true
    c.context_menu  = [:delete]
    c.permissions   = {create: false, update: false}
    c.multi_select  = false

    c.view_config = {enable_text_selection: true, load_mask:false}

    column_defaults = {
      read_only:     true,
      sortable:      false,
      fixed:         true,
      menu_disabled: true,
      draggable:     false,
      align:         :center,
      td_cls:        'regular-cell',
    }

    c.columns = [
      column_defaults.merge(
        name:  :row_number,
        text:  '#',
        xtype: :rownumberer,
        width: 50,
        td_cls: 'key-cell',
      ),
      column_defaults.merge(
        name: :ptu_build_id,
        text: 'Build ID',
      ),
      column_defaults.merge(
        name:   :exposed_host,
        text:   'Exposed as',
        width:  200,
      ),
      column_defaults.merge(
        name:   :target_host,
        text:   'Destination',
        width:  250,
      ),
      column_defaults.merge(
        name:  :os,
        text:  'OS',
        width: 200,
      ),
      column_defaults.merge(
        name:   :last_connected_at,
        text:   'Last connected',
        width:  200,
        format: 'Y-m-d H:i T',
        getter: lambda { |r| last_connected_at(r.container.connections) },
      ),
      column_defaults.merge(
        name:   :connection_state,
        text:   'State',
        width:  100,
        getter: lambda { |r|  "<div class='state-#{connection_state(r.container).to_s}'>#{connection_state(r.container).to_s.upcase}<div>" },
      ),
      column_defaults.merge(
        name:   :direct_remote,
        text:   'Direct remote',
        width:  200,
        getter: lambda { |r| direct_remote(r.container.direct_remote) },
      ),
      column_defaults.merge(
        name:   :forwarded_remotes,
        text:   'Forwarded remotes',
        flex:   true,
        align:  :left,
        getter: lambda { |r| forwarded_remotes(r.container.forwarded_remotes) },
      ),
    ]

    c.tbar = ['->', :delete]
    c.bbar = ['->', :delete]

    c.init_component = l(<<-JS)
      function() {
        // Call superclass's initComponent
        this.superclass.initComponent.call(this);
        // Set timer to reload data store
        this.on('afterrender', function(self, eOpts) {
          Ext.TaskManager.start({
            run: function() { self.store.load() },
            interval: 5000
          });
        }, this);
      }
      JS
  end

end
