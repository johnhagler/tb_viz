// Generated by CoffeeScript 1.12.2
(function() {
  var colors, draw_map, draw_points, fmt, handle_results, height, incidence_transform, projection, svg, t, width;

  svg = d3.select('svg#map');

  height = svg.attr('height');

  width = svg.attr('width');

  projection = d3.geo.equirectangular().scale(150).translate([width / 2, height / 2 + 30]);

  fmt = d3.format('#,###');

  colors = {
    'High-income': '#e41a1c',
    'Upper-middle-income': '#377eb8',
    'Lower-middle-income': '#4daf4a',
    'Low-income': '#984ea3'
  };

  t = function(lat, lon) {
    var pos;
    pos = projection([lon, lat]);
    return "translate(" + pos[0] + "," + pos[1] + ")";
  };

  incidence_transform = function(d) {
    d.Incidence = +d.Incidence;
    return d;
  };

  draw_map = function(data) {
    return svg.append('path').attr('class', 'map').datum(data).attr('d', d3.geo.path().projection(projection));
  };

  draw_points = function(data) {
    var extents, r_scale;
    extents = d3.extent(data, function(d) {
      return d.Incidence;
    });
    r_scale = d3.scale.sqrt().range([.5, 20]).domain(extents);
    svg.selectAll('circle').data(data, function(d) {
      return d['Country'];
    }).enter().append('circle').attr('transform', function(d) {
      return t(d.Lat, d.Lon);
    }).attr('r', function(d) {
      return r_scale(d.Incidence);
    }).attr('opacity', .5).attr('fill', function(d) {
      return colors[d.Group];
    });
    d3.selectAll('#map circle').on('mouseover', function(d) {
      var circle, hover, text;
      circle = d3.select(this);
      hover = svg.append('g').attr('class', 'map-hover').attr('transform', circle.attr('transform'));
      text = hover.insert('text');
      text.append('tspan').text(d.Country).attr('dx', 10);
      return text.append('tspan').text(fmt(d.Incidence)).attr('x', 0).attr('dx', 10).attr('dy', '1em');
    });
    d3.selectAll('#map circle').on('mouseout', function() {
      return d3.select('.map-hover').remove();
    });
    return this.map.update = function(year) {
      var d, filtered;
      filtered = (function() {
        var j, len, results1;
        results1 = [];
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          if (d.Year === year) {
            results1.push(d);
          }
        }
        return results1;
      })();
      return svg.selectAll('circle').data(filtered, function(d) {
        return d['Country'];
      }).transition().duration(300).delay(function(d, i) {
        return i / filtered.length * 500;
      }).ease('variable').attr('r', function(d) {
        return r_scale(d.Incidence);
      });
    };
  };

  handle_results = function(error, results) {
    var d, j, len, map_data, tb_data;
    if (error) {
      console.log(error);
    }
    map_data = results[0];
    tb_data = results[1];
    for (j = 0, len = tb_data.length; j < len; j++) {
      d = tb_data[j];
      d.Incidence = +d.Incidence;
    }
    draw_map(map_data);
    return draw_points(tb_data);
  };

  d3.queue().defer(d3.json, 'countries.geo.json').defer(d3.csv, 'incidence.csv').awaitAll(handle_results);

}).call(this);

//# sourceMappingURL=map.js.map
