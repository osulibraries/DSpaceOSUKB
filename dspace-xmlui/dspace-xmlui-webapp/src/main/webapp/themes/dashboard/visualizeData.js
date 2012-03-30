var dataValue = [];
var addedTitle, totalTitle;

//Get all the data we need
$('#aspect_dashboard_DashboardViewer_table_items_added_monthly tr.ds-table-row').each(function(){
    var rowDate = $(this).find('.date').html();
    var rowItemsAdded = $(this).find('.items_added').html();
    var rowItemsTotal = $(this).find('.items_total').html();
    dataValue.push([new Date(rowDate.substring(0,4), rowDate.substring(5,7), 1), rowItemsAdded*1, rowItemsTotal*1]);
    addedTitle = 'Items Added';
    totalTitle = 'Total Items';
});

var total = 0;
$('#aspect_dashboard_ElasticSearchStatsViewer_table_MonthlyDownloads tr.ds-table-row').each(function(){
    var rowDate = $(this).find('.date').html();
    var rowItemsAdded = $(this).find('.count').html();
    total = total + rowItemsAdded*1;
    dataValue.push([new Date(rowDate.substring(0,4), rowDate.substring(5,7), 1), rowItemsAdded*1]);

    addedTitle = 'Downloads';
    totalTitle = 'Total Downloads';
});

var countryDataValue = [];
$('#aspect_dashboard_ElasticSearchStatsViewer_table_facet-Country tr.ds-table-row').each(function(){
    var country = $(this).find('.country').html();
    var count = $(this).find('.count').html();

    countryDataValue.push([country, count*1]);
});


//Build the google visualization
google.load('visualization', '1',{'packages':['annotatedtimeline', 'geochart']});
google.setOnLoadCallback(drawChart);
function drawChart()
{
    var data = new google.visualization.DataTable();
    data.addColumn('date', 'Date');
    data.addColumn('number', addedTitle);
    //data.addColumn('number', totalTitle);
    data.addRows(dataValue);
    var chart = new google.visualization.AnnotatedTimeLine(document.getElementById('chart_div'));
    chart.draw(data, {displayAnnotations: true});


    //Country Map
    var dataMap = new google.visualization.DataTable();
    dataMap.addColumn('string', 'Country');
    dataMap.addColumn('number', 'Popularity');
    dataMap.addRows(countryDataValue);

    var options = {};
    var mapDiv = document.getElementById('aspect_dashboard_ElasticSearchStatsViewer_div_chart_div_map');
    $('#aspect_dashboard_ElasticSearchStatsViewer_div_chart_div_map').height(500).width(780);
    var chartMap = new google.visualization.GeoChart(mapDiv);
    chartMap.draw(dataMap, options);



}