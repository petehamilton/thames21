@module "T21", ->
    class @LocationPlacer
      placeTreasureOnMap: (map, location) ->
        @handler = new T21.LocationHandler()
        latlon = location.getLocation()

        marker = new google.maps.Marker(
            position: new google.maps.LatLng(latlon.lat, latlon.lon);
            map: map
            title: "Hello World!"
        )

        listElement = $("<li class='treasure_element' id='" + location.getHashcode() + "'>" + location.getName() + "</li>")

        location.setMarker(marker)
        location.setListElement(listElement)
        location.paintToSidebar()
        T21.locations.push(location)

        # Add a callback to call the highlight method on the
        # location object (pushed to the T21.locations above).
        # This is how we're going to highlight the item in the
        # list.
        google.maps.event.addListener marker, 'click', () =>
          @handler.unhighlightAllLocations()
          location.highlight()

        listElement.bind 'click', () =>
          @handler.unhighlightAllLocations()
          location.highlight()

      placeUserOnMap: (map, location) ->

        marker = new google.maps.Marker(
            position: new google.maps.LatLng(location.lat, location.lon);
            map: map
            title: "Your current location"
            icon: "http://www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png"
        )

        infowindow = new google.maps.InfoWindow(
            content: "Your current location"
        )

        google.maps.event.addListener marker, 'click', () =>
              infowindow.open(map,marker)
