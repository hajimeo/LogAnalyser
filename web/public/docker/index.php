<?php
/**
 * Created by IntelliJ IDEA.
 * User: hajime
 * Date: 25/9/18
 * Time: 4:11 PM
 */
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Making a Dashboard</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.2/d3.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.8.6/nv.d3.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.8.6/nv.d3.css">
</head>
<body>

<div id="averageDegreesLineChart" class='with-3d-shadow with-transitions averageDegreesLineChart'>
    <svg></svg>
</div>

<script>
    var temperatureIndexJSON = [
        {
            key: "Temp +- Avg.",
            values: [{"x": 1998, "y": 0.45}, {"x": 1999, "y": 0.48}, {"x": 2000, "y": 0.5}, {
                "x": 2001,
                "y": 0.52
            }, {"x": 2002, "y": 0.55}, {"x": 2003, "y": 0.58}, {"x": 2004, "y": 0.6}, {
                "x": 2005,
                "y": 0.61
            }, {"x": 2006, "y": 0.61}, {"x": 2007, "y": 0.61}, {"x": 2008, "y": 0.62}, {
                "x": 2009,
                "y": 0.62
            }, {"x": 2010, "y": 0.62}, {"x": 2011, "y": 0.63}, {"x": 2012, "y": 0.67}, {
                "x": 2013,
                "y": 0.71
            }, {"x": 2014, "y": 0.77}, {"x": 2015, "y": 0.83}, {"x": 2016, "y": 0.89}, {"x": 2017, "y": 0.95}]
        }
    ];

    nv.addGraph(function () {
        var chart = nv.models.lineChart() // Initialise the lineChart object.
            .useInteractiveGuideline(true); // Turn on interactive guideline (tooltips)
        chart.xAxis
            .axisLabel('TimeStamp (Year)'); // Set the label of the xAxis (Vertical)
        chart.yAxis
            .axisLabel('Degrees (c)') // Set the label of the xAxis (Horizontal)
            .tickFormat(d3.format('.02f')); // Rounded Numbers Format.
        d3.select('#averageDegreesLineChart svg') // Select the ID of the html element we defined earlier.
            .datum(temperatureIndexJSON) // Pass in the JSON
            .transition().duration(500) // Set transition speed
            .call(chart); // Call & Render the chart
        nv.utils.windowResize(chart.update); // Intitiate listener for window resize so the chart responds and changes width.
        return;
    });
</script>
</body>
</html>
