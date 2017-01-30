years = ['1995','2000','2005','2010','2015']


# update function
update_vis = (year) ->
  window.slope.update(year)
  window.map.update(year)



d3.select('#a-years').selectAll('.btn')
  .on('click', -> 
      btn = d3.select(this)
      year = btn.attr('data-year')
      
      d3.selectAll('#a-years .btn').classed('active', false)
      btn.classed('active', true)

      update_vis(year)

  )


d3.select('#play')
  .on('click', -> play())


# setup animation to play through
i = 0
this.play = ->
  if i < 5
    d3.select('#play i').classed('fa-play-circle', false)
    d3.select('#play i').classed('fa-play-circle-o', true)

    year = years[i]


    $('[data-year]').removeClass('active', false)
    $("[data-year=#{year}]").addClass('active', true)

    update_vis(years[i])

    i++
    window.setTimeout(play, 2000)
    
  else
    i = 0
    d3.select('#play i').classed('fa-play-circle', true)
    d3.select('#play i').classed('fa-play-circle-o', false)

