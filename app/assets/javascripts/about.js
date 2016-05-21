$(document).ready(function () {
  $(function () {
    $("#about-dialog").dialog({
      width: 800,
      height: 650,
      autoOpen: false,
      modal: true,
      dialogClass: "about",
      draggable: false,
      resizable: false,
      open: function() { $('.ui-widget-overlay').bind('click', function() { $('#about-dialog').dialog('close'); }) },
    });
  });
});
