# This is how we require other JS deps!

#= require rails
#= require log_plugin
#= require dotimeout_plugin
#= require facebox
# require bootstrap

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
  T21.markers = []
  T21.info_windows = []
  for treasureJsonObject in treasureJsonObjects
    # log treasureJsonObject
    # log "Adding at ", treasureJsonObject.lat, treasureJsonObject.lng

    treasure_pos = new google.maps.LatLng(treasureJsonObject.lat, treasureJsonObject.lng);
    # log T21.location.lat(), T21.location.lng(), treasure_pos.lat(), treasure_pos.lng()
    
    if (treasureJsonObject.hyperlink == "")
      html = '<h1>' + treasureJsonObject.name + '</h1><p>' + treasureJsonObject.description + '</p>';
    else
      html = '<a href="' + treasureJsonObject.hyperlink + '"><h1>' + treasureJsonObject.name + '</h1></a><p>' + treasureJsonObject.description + '</p>';
    
    marker = new google.maps.Marker
      map: T21.map,
      draggable: false,
      animation: google.maps.Animation.DROP,
      position: treasure_pos
      html: html

    google.maps.event.addListener marker, 'click', () ->
      T21.infowindow.setContent(this.html);
      T21.infowindow.open(T21.map, this);

resizeContentToWindow = ->
  $('#main').height($(window).height() - 80)

setupGoogleMap = ->
  central_london = new google.maps.LatLng(51.50243858499476, -0.07020938574214375)
  T21.location = central_london

  opts =
    zoom: 14
    center: T21.location
    mapTypeId: google.maps.MapTypeId.ROADMAP

  T21.map = new google.maps.Map(document.getElementById("map_canvas"), opts);

  google.maps.event.addListener T21.map, 'center_changed', () ->
    T21.location = T21.map.getCenter()

bindButtons = ->
  $("#add_treasure_btn").click () ->
    # $.facebox({ ajax: '/treasures/new' })
    addNewTreasureMarker()
  
  $('.save_form').live 'click', () ->
    
    form = $(this).parents('form:first')
    data = $(form).serialize()
    url = $(form).attr 'action'
    method = $(form).attr 'method'
    
    data += "&_method=" + method
    $.post url, data, null, 'script'
    
    return false;

addNewTreasureMarker = ->
  c = T21.map.getCenter()
  
  T21.newmarker = new google.maps.Marker
    map:T21.map
    draggable:true
    animation: google.maps.Animation.DROP
    position: c
    icon: "http://www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png"
  
  
  $.get '/treasures/new', (data) ->
    T21.infowindow.setContent(data)
    T21.infowindow.open(T21.map, T21.newmarker)
  
  google.maps.event.addListener T21.newmarker, 'click', () ->
    if marker.getAnimation() != null
      marker.setAnimation null
    else
      marker.setAnimation google.maps.Animation.BOUNCE
  
  google.maps.event.addListener T21.newmarker, 'dragend', () ->
    center = T21.newmarker.getPosition()
    $("#treasure_lat").val(center.lat())
    $("#treasure_lng").val(center.lng())
  
  $("#treasure_lat").val(c.lat())
  $("#treasure_lng").val(c.lng())

$(document).ready ->
  resizeContentToWindow()
  $(window).resize resizeContentToWindow
  setupFacebox()
  setupGoogleMap()
  T21.infowindow = new google.maps.InfoWindow
  T21.location = T21.map.getCenter()
  T21.loadTreasures()
  bindButtons()
