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

  app.ports.onMarkerCreation.send(marker._leaflet_id)
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
  var app = Elm.Main.embed(node);

  app.ports.initMap.subscribe(function(mapData) {
    initMap(mapData);
  });

  app.ports.addMarker.subscribe(function(markerData) {
    addMarker(markerData, app)
  });

  app.ports.addMarkers.subscribe(function(markers) {
    markers.forEach(function(marker) {
      addMarker(marker, app);
    });
  });

  app.ports.updateIcon.subscribe(updateIcon);

  app.ports.updateIcons.subscribe(function(iconsData) {
    iconsData.forEach(function(iconData) {
      updateIcon(iconData);
    });
  });
}(window));
