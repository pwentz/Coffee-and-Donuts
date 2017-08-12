"use strict";

var myMap;
var app;

function initMap(data) {
  myMap = L.map(data.divId)
           .setView([data.lat, data.lng], data.zoom);

  L.tileLayer(data.tileLayer, data.tileLayerOptions)
   .addTo(myMap);
};

function addMarker(options) {
  var icon = options.icon && { iconUrl: options.icon.url,
                               iconSize: [options.icon.size.height, options.icon.size.width] }

  var markerOptions = icon ? { icon: L.icon(icon), draggable: options.draggable }
                           : { draggable: options.draggable }

  var marker = L.marker([options.lat, options.lng], markerOptions)

  marker.addTo(myMap);

  if (options.popup) {
    marker.bindPopup(options.popup)
  }

  if (options.events) {
    options.events.forEach(function(eventData) {
      var event = eventData.event;
      var action = eventData.action;
      var didSubscribe = eventData.subscribe;

      marker.on(event, function(e) {
        action && marker[action]();

        didSubscribe &&
          app.ports.onMarkerEvent.send({
            event: event,
            lat: options.lat,
            lng: options.lng,
            targetId: marker._leaflet_id
          });
      });
    });
  };

  app.ports.onMarkerCreation.send({
    id: marker._leaflet_id,
    lat: options.lat,
    lng: options.lng
  });
};


function updateIcon(options) {
  var layers = myMap._layers
  var targetMarker = layers[options.id];

  var icon = { iconUrl: options.icon.url,
               iconSize: [options.icon.size.height, options.icon.size.width] }

  targetMarker.setIcon(L.icon(icon));
};

(function(window) {
  var node = document.getElementById("app");
  app = Elm.Main.embed(node);
  var safe = function(fn, data) {
      try { fn(data) }
      catch (err) { app.ports.jsError.send(err.message) }
  };

  var actions = {
    initMap: initMap,
    addMarker: addMarker,
    addMarkers: function(markers) { markers.forEach(addMarker); },
    updateIcon: updateIcon,
    updateIcons: function(icons) { icons.forEach(updateIcon); }
  };

  Object.keys(actions).forEach(function(action) {
    var safeAction = safe.bind(null, actions[action]);
    app.ports[action].subscribe(safeAction);
  });
}(window));
