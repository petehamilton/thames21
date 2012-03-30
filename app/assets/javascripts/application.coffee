# This is how we require other JS deps!

#= require rails
#= require log_plugin
#= require dotimeout_plugin
#= require facebox

#= require _helpers

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
  return T21.getTreasureJSON(T21.parseTreasureJSON, map, sort)

T21.getTreasureJSON = (afterFunction, map = T21.map, sort = "none") ->
  $.ajax '/treasures',
    type: 'GET'
    dataType: 'json'
    data:
      lat: T21.location.lat()
      lon: T21.location.lng()
      sort: sort
    error: (jqXHR, textStatus, errorThrown) ->
      return false
    success: (data, textStatus, jqXHR) ->
      afterFunction(data, map)
      return true

T21.parseTreasureJSON = (treasureJsonObjects, map = T21.map) ->
  T21.treasure_markers = []
  for treasureJsonObject in treasureJsonObjects
    # log treasureJsonObject
    # log "Adding at ", treasureJsonObject.lat, treasureJsonObject.lng

    treasure_pos = new google.maps.LatLng(treasureJsonObject.lat, treasureJsonObject.lng);
    log T21.location.lat(), T21.location.lng(), treasure_pos.lat(), treasure_pos.lng()
    marker = new google.maps.Marker
      map: T21.map,
      draggable: false,
      animation: google.maps.Animation.DROP,
      position: treasure_pos

    T21.treasure_markers.push marker

  marker = new google.maps.Marker
    map: T21.map,
    draggable: false,
    animation: google.maps.Animation.DROP,
    position: T21.location

resizeContentToWindow = ->
  $('#main').height($(window).height() - 80)

setupGoogleMap = ->
  central_london = new google.maps.LatLng(51.485766, -0.136814)
  T21.location = central_london

  opts =
    zoom: 13
    center: T21.location
    mapTypeId: google.maps.MapTypeId.ROADMAP

  T21.map = new google.maps.Map(document.getElementById("map_canvas"), opts);

  google.maps.event.addListener T21.map, 'center_changed', () ->
    T21.location = T21.map.getCenter()
  #   # log T21.location.lat(), T21.location.lng()
  #
  #   $.doTimeout 't21_treasures_load', 1000, () ->
  #     alert "Should have loaded once"
  #     T21.loadTreasures()

$(document).ready ->
  resizeContentToWindow()
  $(window).resize resizeContentToWindow
  setupFacebox()
  setupGoogleMap()
  T21.location = T21.map.getCenter()
  T21.loadTreasures()
