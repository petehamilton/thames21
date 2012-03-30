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

T21.fit_zoom = ->
  bounds = new google.maps.LatLngBounds()
  for location in T21.locations
    loc = location.getLocation()
    latlng = new google.maps.LatLng(loc.lat, loc.lon)
    bounds.extend (latlng)
  T21.map.fitBounds(bounds)

T21.loadTreasures = (map = T21.map, sort = "none") ->
  for l in T21.locations
    l.remove()
  T21.locations = []
  return getTreasureJSON(parseTreasureJSON, map, sort)

getTreasureJSON = (afterFunction, map = T21.map, sort) ->
  location = T21.geoLocationHandler.getLocation()
  $.ajax '/treasures',
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

parseTreasureJSON = (treasureJsonObjects, map = T21.map) ->
  placer = new T21.LocationPlacer()
  for treasureJsonObject in treasureJsonObjects
    treasure = new T21.Location(treasureJsonObject)
    placer.placeTreasureOnMap(map, treasure)
  T21.fit_zoom()

resizeContentToWindow = ->
  $('#main').height($(window).height() - 80)

bindFilterButtons = ->
  $('#treasure_filter_button_distance').bind 'click', (event) =>
    $('.treasure_filter_button').removeClass('active')
    $('#treasure_filter_button_distance').addClass('active')
    T21.loadTreasures(T21.map)
  $('#treasure_filter_button_agony').bind 'click', (event) =>
    $('.treasure_filter_button').removeClass('active')
    $('#treasure_filter_button_agony').addClass('active')
    T21.loadTreasures(T21.map, 'agony')
  $('#treasure_filter_button_wait').bind 'click', (event) =>
    $('.treasure_filter_button').removeClass('active')
    $('#treasure_filter_button_wait').addClass('active')
    T21.loadTreasures(T21.map, 'wait')

$(document).ready ->  
  resizeContentToWindow()
  $(window).resize resizeContentToWindow
  
  setupFacebox()
  
  bindFilterButtons();

  # Temp map stuff
  myOptions =
    zoom: 6
    mapTypeId: google.maps.MapTypeId.ROADMAP
  
  T21.map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  
  T21.geoLocationHandler = new T21.GeolocationHandler()
  T21.geoLocationHandler.locateUser()
  location = T21.geoLocationHandler.getLocation()
  T21.map.setCenter (new google.maps.LatLng(location.lat,location.lon))
  
  if !T21.loadTreasures()
    log "Failed to load treasure data"
