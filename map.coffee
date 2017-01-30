svg = d3.select('svg#map')
height = svg.attr('height')
width = svg.attr('width')

projection = d3.geo.equirectangular()
  .scale(150)
  .translate([width/2, height/2 + 30])
fmt = d3.format('#,###')
colors = {
  'High-income':'#e41a1c'
  'Upper-middle-income':'#377eb8'
  'Lower-middle-income':'#4daf4a'
  'Low-income':'#984ea3'
}

t = (lat, lon) ->
  pos = projection([lon, lat])
  return "translate(#{pos[0]},#{pos[1]})"

incidence_transform = (d) ->
  d.Incidence = +d.Incidence
  return d


draw_map = (data) ->  
  svg.append('path')
    .attr('class', 'map')
    .datum(data)
    .attr('d', d3.geo.path().projection(projection))


draw_points = (data) ->
 
  extents = d3.extent(data, (d) -> d.Incidence)
  r_scale = d3.scale.sqrt().range([.5,20]).domain(extents);

  svg.selectAll('circle')
    .data(data, (d) -> d['Country'])
    .enter()
    .append('circle')
    .attr('transform', (d) -> t(d.Lat, d.Lon))
    .attr('r', (d) -> r_scale(d.Incidence))
    .attr('opacity', .5)
    .attr('fill', (d) -> colors[d.Group])


  d3.selectAll('#map circle').on('mouseover', (d) ->
    circle = d3.select(this)
    hover = svg.append('g')
      .attr('class', 'map-hover')
      .attr('transform', circle.attr('transform'))

    text = hover.insert('text')
      
    text.append('tspan')
      .text(d.Country)
      .attr('dx', 10)
    text.append('tspan')
      .text(fmt d.Incidence)
      .attr('x', 0)
      .attr('dx', 10)
      .attr('dy', '1em')

  )

  d3.selectAll('#map circle').on('mouseout', ->
    d3.select('.map-hover').remove()
    
  )


  # expose as global
  this.map.update = (year) ->
    filtered = (d for d in data when d.Year == year)
    svg.selectAll('circle')
      .data(filtered, (d) -> d['Country'])
      .transition()
      .duration(300)
      .delay((d, i) -> i / filtered.length * 500)
      .ease('variable')
      .attr('r', (d) -> r_scale(d.Incidence))
    

  

handle_results = (error, results) ->
  if error
    console.log(error)

  map_data = results[0]
  tb_data = results[1]
  
  for d in tb_data
    d.Incidence = +d.Incidence

  draw_map map_data
  draw_points tb_data



d3.queue()
  .defer(d3.json, 'countries.geo.json')
  .defer(d3.csv, 'incidence.csv')
  .awaitAll(handle_results)
