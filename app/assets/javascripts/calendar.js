# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready(function() {
   $("#calendar").fullCalendar({
     header: "calendar-header",
     left: "prev,next today",
     center: "title",
     right: "month,agendaWeek,agendaDay",
     defaultView: "month",
     height: 500,
     slotMinutes: 15,
     events: "/calendar/get_events",
     timeFormat: "h:mm t{ - h:mm t} ",
     dragOpacity: "0.5"
  });
});