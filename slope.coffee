svg = d3.select('svg#slope')
height = svg.attr('height')
width = svg.attr('width')
padding = 20
duration = 1000

format = d3.format(',%')
colors = [
  '#e41a1c'
  '#377eb8'
  '#4daf4a'
  '#984ea3']

# Create scale functions
x_scale = d3.scale.linear() 
  .domain([0, 1])
  .range([padding + 80, width - 250]);

y_scale = d3.scale.linear() 
  .domain([0, 1])
  .range([height - padding, padding])

# Define Y axis
y_axis = d3.svg.axis()
  .scale(y_scale)
  .orient('left')
  .tickFormat(format)
  .ticks(4);


# x axis labels
svg.append('text')
  .attr('x', x_scale(0))
  .attr('y', height - 5)
  .attr('text-anchor', 'middle')
  .text('Immunization');
svg.append('text')
  .attr('x', x_scale(1))
  .attr('y', height - 5)
  .attr('text-anchor', 'middle')
  .text('Treatment');

# Add to Y axis
svg.append('g')
  .attr('class', 'y axis')
  .attr('transform', 'translate(' + (padding + 15) + ',0)')
  .call(y_axis);




draw = (data) ->

  # draw legend
  legend_svg = d3.select("#legend")
  series = d3.nest()
    .key((d) -> d['Income Group'])
    .rollup(-> {})
    .entries(data)

  legend = legend_svg.append('g')
        .attr('class', 'legend')

  s = legend.selectAll('.series')
      .data(series)
      .enter()
      .insert('g')
      .attr('class', 'series')

  s.insert('text')
      .text((d) -> d.key)
      .attr('x', 15)
      .attr('y', 15)  


  s.insert('circle')
      .attr('cx', 0)
      .attr('cy', 10)
      .attr('r', 8)
      .attr('fill', (d, i) -> colors[i])    

  xpos = 0
  newxpos = 15
  s.attr('transform', (d,i)->  
    xpos = newxpos
    length = d3.select(this).select('text').node().getComputedTextLength() + 50
    newxpos += length
    return "translate(#{xpos}, 5)"
  )
  



  # create group for each slope
  g = svg.selectAll('g.slope-group')
    .data(data, (d) -> d['Income Group'])
    .enter()
    .append('g')
    .attr('class', 'slope-group')

  # add start point
  g.insert('circle')
    .attr('class', 'start')
    .attr('cx', (d) -> x_scale 0)
    .attr('cy', (d) -> y_scale d.Immunization)
    .attr('fill', (d, i) ->colors[i])
    .attr('r', 6)

  # add ending point
  g.insert('circle')
    .attr('class', 'end')
    .attr('cx', (d) -> x_scale 1)
    .attr('cy', (d) -> y_scale d.Treatment)
    .attr('fill', (d, i) -> colors[i])
    .attr('r', 6)

  # add slope line
  g.insert('line')
    .attr('class', 'slope')
    .attr('x1', x_scale 0 )
    .attr('x2', x_scale 1 )
    .attr('y1', (d) -> y_scale d.Immunization)
    .attr('y2', (d) -> y_scale d.Treatment)
    .attr('stroke', (d, i) -> colors[i])
    .attr('stroke-width', 6)

  # add stat text label
  g.insert('text')
    .attr('class', 'start')
    .text((d) -> format d.Immunization)
    .attr('text-anchor', 'end')
    .attr('x', x_scale(0) - 10)
    .attr('y', (d) -> y_scale(d.Immunization) + 5)

  # add end text label
  g.insert('text')
    .attr('class', 'end')
    .text((d) -> format d.Treatment)
    .attr('x', x_scale(1) + 10)
    .attr('y', (d) -> y_scale(d.Treatment) + 5)



  #utility show/hide function
  show = ->
    d3.select(this).selectAll('text.start, text.end')
      .classed('show', true)
  hide = ->
    d3.select(this).selectAll('text.start, text.end')
      .classed('show', false)

  # add mouseover/mouseout handlers to show and hide labels
  d3.selectAll('g.slope-group')
    .on('mouseover', show)
  d3.selectAll('g.slope-group')
    .on('mouseout', hide)



  # update function
  this.slope.update = (year) ->
    
    filtered = (d for d in data when d.Year == year)

    key_fn = (d) -> d['Income Group']

    # update starting point
    svg.selectAll('circle.start')
      .data(filtered, key_fn)
      .transition()
      .duration(duration)
      .ease('variable')
      .attr('cx', (d) -> x_scale 0 )
      .attr('cy', (d) -> y_scale d.Immunization )

    # update ending point
    svg.selectAll('circle.end')
      .data(filtered, key_fn)
      .transition()
      .duration(duration)
      .ease('variable')
      .attr('cx', (d) -> x_scale 1 )
      .attr('cy', (d) -> y_scale d.Treatment )

    # update line
    svg.selectAll('line.slope')
      .data(filtered, key_fn)
      .transition()
      .duration(duration)
      .ease('variable')
      .attr('y1', (d) -> y_scale d.Immunization )
      .attr('y2', (d) ->  y_scale d.Treatment )

    # update start label text and position
    svg.selectAll('text.start')
      .data(filtered, key_fn)
      .text((d) -> format d.Immunization)
      .attr('y', (d) -> y_scale(d.Immunization) + 5)

    # update end label text and position
    svg.selectAll('text.end')
      .data(filtered, key_fn)
      .text((d) -> format d.Treatment)
      .attr('y', (d) -> y_scale(d.Treatment) + 5)




# load data and draw graph
d3.csv('income_group.csv', draw)




