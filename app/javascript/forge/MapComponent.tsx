const google = window.google

export function propertyChanged(props, prevProps, property) {
  return (!prevProps[property] && props[property]) || (prevProps[property] !== props[property])
}

export function addOpacity(map, layers) {
  const currentLayers = map.overlayMapTypes.getArray()
  currentLayers.forEach(layer => {
    const opacity = layers.find(l => l.id === layer.name).opacity
    if (typeof (opacity) === 'number') { layer.setOpacity(opacity / 100) } else { layer.setOpacity(1) }
  })
}

export function generateMarkers(items, handlers) {
  if (!items) return null

  const markers = {}
  items.forEach(item => {
    const lat = item.lat || item.latitude
    const lon = item.lon || item.longitude
    const marker = new google.maps.Marker({
      position: new google.maps.LatLng(lat, lon),
      icon: getStaticIcon(),
      zIndex: 10
    })
    marker.buildingId = item.id
    google.maps.event.addListener(marker, 'click', () => {
      handlers.onClick(item)
    })
    google.maps.event.addListener(marker, 'mouseover', () => {
      handlers.onMouseOver(item, marker)
    })
    google.maps.event.addListener(marker, 'mouseout', () => {
      handlers.onMouseOut(item)
    })
    markers[marker.buildingId] = marker
  })
  return markers
}

export function highlightMarkers(props, prevProps, markers) {
  const wasHighlighted = parseInt(prevProps.highlighted)
  const isHighlighted = parseInt(props.highlighted)
  const buildingId = props.building && parseInt(props.building.id)
  if (wasHighlighted && wasHighlighted !== isHighlighted) {
    unhighlightMarker(wasHighlighted, markers)
  }
  if (isHighlighted) {
    highlightMarker(isHighlighted, markers)
  } else if (buildingId) {
    highlightMarker(buildingId, markers)
  }
}

function tweakMarker(id, icon, zIndex, markers) {
  const marker = markers[id]
  marker.setIcon(icon)
  marker.setZIndex(zIndex)
}

export function highlightMarker(id, markers) {
  tweakMarker(id, getHoverIcon(), 100, markers)
}

export function unhighlightMarker(id, markers) {
  tweakMarker(id, getStaticIcon(), 10, markers)
}

function getBaseIcon() {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillOpacity: 0.9,
    scale: 6,
    strokeColor: '#333',
    strokeWeight: 1
  }
}

function getHoverIcon() {
  return Object.assign({}, getBaseIcon(), {
    fillColor: 'blue'
  })
}

function getStaticIcon() {
  return Object.assign({}, getBaseIcon(), {
    fillColor: 'red'
  })
}

export function getMainIcon() {
  return Object.assign({}, getBaseIcon(), {
    fillColor: 'green',
    scale: 10
  })
}
