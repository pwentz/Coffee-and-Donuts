"use strict";

var myMap;

function initMap(data) {
  myMap = L.map(data.divId)
           .setView([data.lat, data.lng], data.zoom);

  L.tileLayer(data.tileLayer, data.tileLayerOptions)
   .addTo(myMap);
};

function addMarker(options, app) {
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

function addMarkers(markers, app) {
  markers.forEach(function(marker) {
    addMarker(marker, app);
  })
}

function updateIcons(icons) {
  icons.forEach(updateIcon)
}


(function(window) {
  var node = document.getElementById("app");
  var app = Elm.Main.embed(node);
  var safe = function(fn) { try { fn() } catch (err) { app.ports.jsError.send(err.message) } }

  var actions = {
    initMap: function(data) { safe(initMap.bind(null, data)) },
    addMarker: function(data) { safe(addMarker.bind(null, data, app)) },
    addMarkers: function(markers) { safe(addMarkers.bind(null, markers, app)) },
    updateIcon: function(icon) { safe(updateIcon.bind(null, icon)) },
    updateIcons: function(icons) { safe(updateIcons.bind(null, icons)) }
  }

  Object.keys(actions).forEach(function(action) {
    app.ports[action].subscribe(actions[action]);
  });
}(window));
