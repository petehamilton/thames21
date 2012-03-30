# This is how we require other JS deps!

#= require rails
#= require log_plugin
#= require dotimeout_plugin
#= require jspostcode
#= require facebox

#= require _helpers
#= require geolocation_handler
#= require location
#= require location_handler
#= require location_placer

setupFacebox = ->
  $.facebox.settings.closeImage = '/assets/facebox/closelabel.png'
  $.facebox.settings.loadingImage = '/assets/facebox/loading.gif'
  $('a[rel*=facebox]').facebox()
  $(document).bind('loading.facebox', ->
    e = $('#facebox .content').first()
    e.removeAttr('class')
    e.addClass('content')
  )

EMG.fit_zoom = ->
  bounds = new google.maps.LatLngBounds()
  for location in EMG.locations
    loc = location.getLocation()
    latlng = new google.maps.LatLng(loc.lat, loc.lon)
    bounds.extend (latlng)
  EMG.map.fitBounds(bounds)

EMG.loadHospitals = (map = EMG.map, sort = "none") ->
  for l in EMG.locations
    l.remove()
  EMG.locations = []
  return getHospitalJSON(parseHospitalJSON, map, sort)

getHospitalJSON = (afterFunction, map = EMG.map, sort) ->
  location = EMG.geoLocationHandler.getLocation()
  $.ajax '/hospitals',
    type: 'GET'
    dataType: 'json'
    data:
      lat: location.lat
      lon: location.lon
      sort: sort
    error: (jqXHR, textStatus, errorThrown) ->
      return false
    success: (data, textStatus, jqXHR) ->
      afterFunction(data, map)
      return true

parseHospitalJSON = (hospitalJsonObjects, map = EMG.map) ->
  placer = new EMG.LocationPlacer()
  for hospitalJsonObject in hospitalJsonObjects
    hospital = new EMG.Location(hospitalJsonObject)
    placer.placeHospitalOnMap(map, hospital)
  EMG.fit_zoom()

resizeContentToWindow = ->
  $('#main').height($(window).height() - 80)

bindFilterButtons = ->
  $('#hospital_filter_button_distance').bind 'click', (event) =>
    $('.hospital_filter_button').removeClass('active')
    $('#hospital_filter_button_distance').addClass('active')
    EMG.loadHospitals(EMG.map)
  $('#hospital_filter_button_agony').bind 'click', (event) =>
    $('.hospital_filter_button').removeClass('active')
    $('#hospital_filter_button_agony').addClass('active')
    EMG.loadHospitals(EMG.map, 'agony')
  $('#hospital_filter_button_wait').bind 'click', (event) =>
    $('.hospital_filter_button').removeClass('active')
    $('#hospital_filter_button_wait').addClass('active')
    EMG.loadHospitals(EMG.map, 'wait')

$(document).ready ->  
  resizeContentToWindow()
  $(window).resize resizeContentToWindow
  
  setupFacebox()
  
  bindFilterButtons();

  # Temp map stuff
  myOptions =
    zoom: 6
    mapTypeId: google.maps.MapTypeId.ROADMAP
  
  EMG.map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  
  EMG.geoLocationHandler = new EMG.GeolocationHandler()
  EMG.geoLocationHandler.locateUser()
  location = EMG.geoLocationHandler.getLocation()
  EMG.map.setCenter (new google.maps.LatLng(location.lat,location.lon))
  
  if !EMG.loadHospitals()
    log "Failed to load hospital data"
