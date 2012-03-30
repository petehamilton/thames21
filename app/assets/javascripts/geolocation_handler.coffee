@module "EMG", ->
  class @GeolocationHandler
    constructor: ->
      @location = {'lat': 54.851562, 'lon': -3.977137}
      @locationBeenVerified = false
    
    getLocation: ->
      return @location
    
    #Initiated process of setting the user's location
    locateUser: ->
      if this.browserGeolocationEnabled()
        if this.locationVerified()
          EMG.loadHospitals()
        else
          this.setLocationUsingBrowser()
      else
        this.locateWithPostcode()
    
    # Centers the map on the current user's recorded location
    centerMapOnLocation: ->
      c = new google.maps.LatLng(@location.lat, @location.lon)
      EMG.map.setCenter(c)
    
    # Binds the buttons for the various forms in facebox popups relating 
    # to the geolocation
    bindFaceboxButtons: ->
      if $('#facebox #verify_location')
        $('#facebox #verify_location_button_yes').bind 'click', (event) =>
          this.setLocationVerified(true)
          $.facebox('Thank you for verifying your location.')
          $.doTimeout 1000, =>
            $(document).trigger('close.facebox')
            this.locateUser()
        
        $('#facebox #verify_location_button_no').bind 'click', (event) =>
          this.setLocationVerified(false)
          this.locateWithPostcode()
      if $('#facebox #postcode_form')
        $('#facebox #postcode_button_submit').bind 'click', (event) =>
          this.geocodePostcode()

    placeUserMarker: (location = @location) ->
      placer = new EMG.LocationPlacer()
      placer.placeUserOnMap(EMG.map, location)
    
    # Sets the user's location to 'latlon'
    setLocation: (latlon) ->
      log "Setting location:"
      log latlon
      @location = latlon
      this.placeUserMarker()

    # Zooms in to current location and initiates prompt to get user to verify 
    # the suggested location. Opens the facebox and binds the buttons
    verifyLocation: ->
      this.centerMapOnLocation()
      EMG.map.setZoom(16)
      $.facebox({div : '#verify_location_container'}, 'verify_location')
      this.bindFaceboxButtons()
    
    # Set whether the location has been verified
    setLocationVerified: (lv) ->
      @locationBeenVerified = lv
    
    # Returns whether the location can be obtained from the browser
    browserGeolocationEnabled: ->
      return navigator.geolocation
    
    # Returns whether the user's location has been verified
    locationVerified: ->
      return @locationBeenVerified
    
    # Begins the process of locating the user using their postcode, opens the 
    # facebox and binds the buttons
    locateWithPostcode: ->
      $.facebox({div : '#postcode_form_container'}, 'postcode_form')
      this.bindFaceboxButtons()
    
    # Uses the postcode input textbox, asks google for a geocoded latlong.
    # If google returns one, ask the user to verify if the location is correct
    
    geocodePostcode: ->
      log 'Geocode Postcode'
      postcode = $('#facebox #postcode_text').val()
      log postcode
      if checkPostCode(postcode)
        geocoder = new google.maps.Geocoder();
        geocoder.geocode {'address': postcode + ', UK'}, (result, status) =>
          if status == google.maps.GeocoderStatus.OK
            log result
            latlon = result[0].geometry.location
            this.setLocation {'lat': latlon.lat(), 'lon': latlon.lng()}
            this.verifyLocation()
          else
            $.facebox("Geocode was not successful for the following reason: " + status)
    
    # Gets the user's location from the browser and sets it. Then asks the user 
    # to verify the location is correct
    setLocationUsingBrowser: ->
        if navigator.geolocation
            navigator.geolocation.getCurrentPosition (position) =>
              this.setLocation {'lat': position.coords.latitude, 'lon': position.coords.longitude}
              $.facebox("Location successfully found using HTML5.")
              this.verifyLocation()
            , =>
              $.facebox("Error: The Geolocation service failed.")
        else
            $.facebox("Error: Your browser doesn't support geolocation.")
        
