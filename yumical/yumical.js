function load_calendar(ical) {
  $('#calendar').fullCalendar({
    theme: true,

    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },

    // Public XML Feed
    events: $.fullCalendar.gcalFeed(
      ical,
      { currentTimezone : "America/Phoenix" }
    ),

    eventClick: function(event) {
      var what = event.title;
      var details = event.description;
      var from = event.start;
      var to = event.end;
      var where = event.location;
      $("<div id='dialog' title='" + what + "'>" + 
          "<div class='details'>" + details + "</div>" + 
          "<div class='where'>Where: " + where + " (<a href='http://maps.google.com/?q=" + where + "'>map</a>)</div>" + 
         "</div>").dialog(
        { 
          hide: 'slide',
          stack: false 
        }
      );
      // window.open(event.url, 'gcalevent', 'width=700,height=600');
      return false;
    },

    eventMouseover: function(event) {
      console.log(event);
    },

    loading: function(bool) {
      if (bool) {
        $('#loading').show();
      }else{
        $('#loading').hide();
      }
    }
  });  
}