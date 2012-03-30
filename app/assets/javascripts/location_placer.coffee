@module "EMG", ->
    class @LocationPlacer
      placeHospitalOnMap: (map, location) ->
        @handler = new EMG.LocationHandler()
        latlon = location.getLocation()

        marker = new google.maps.Marker(
            position: new google.maps.LatLng(latlon.lat, latlon.lon);
            map: map
            title: "Hello World!"
        )

        listElement = $("<li class='hospital_element' id='" + location.getHashcode() + "'>" + location.getName() + "</li>")

        location.setMarker(marker)
        location.setListElement(listElement)
        location.paintToSidebar()
        EMG.locations.push(location)

        # Add a callback to call the highlight method on the
        # location object (pushed to the EMG.locations above).
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
