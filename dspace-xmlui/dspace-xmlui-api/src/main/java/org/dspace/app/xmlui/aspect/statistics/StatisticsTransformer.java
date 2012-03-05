/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.statistics;

import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.solr.client.solrj.SolrServerException;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.element.*;
import org.dspace.app.xmlui.wing.element.List;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.*;
import org.dspace.content.Collection;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.statistics.Dataset;
import org.dspace.statistics.ObjectCount;
import org.dspace.statistics.SolrLogger;
import org.dspace.statistics.content.*;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;
import org.xml.sax.SAXException;

public class StatisticsTransformer extends AbstractDSpaceTransformer {

    private static Logger log = Logger.getLogger(StatisticsTransformer.class);

    private static final Message T_dspace_home = message("xmlui.general.dspace_home");
    private static final Message T_head_title = message("xmlui.statistics.title");
    private static final Message T_statistics_trail = message("xmlui.statistics.trail");
    private static final String T_head_visits_total = "xmlui.statistics.visits.total";
    private static final String T_head_visits_month = "xmlui.statistics.visits.month";
    private static final String T_head_visits_views = "xmlui.statistics.visits.views";
    private static final String T_head_visits_countries = "xmlui.statistics.visits.countries";
    private static final String T_head_visits_cities = "xmlui.statistics.visits.cities";
    private static final String T_head_visits_bitstream = "xmlui.statistics.visits.bitstreams";
    
    private Date dateStart = null;
    private Date dateEnd = null;

    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");


    /**
     * Add a page title and trail links
     */
    public void addPageMeta(PageMeta pageMeta) throws SAXException, WingException, UIException, SQLException, IOException, AuthorizeException {
        //Try to find our dspace object
        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);

        pageMeta.addTrailLink(contextPath + "/", T_dspace_home);

        if (dso != null) {
            HandleUtil.buildHandleTrail(dso, pageMeta, contextPath);
        }
        pageMeta.addTrailLink(contextPath + "/handle" + (dso != null && dso.getHandle() != null ? "/" + dso.getHandle() : "/statistics"), T_statistics_trail);

        // Add the page title
        pageMeta.addMetadata("title").addContent(T_head_title);
    }

    /**
     * What to add at the end of the body
     */
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException {

        //Try to find our dspace object
        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);

		try
		{
			if(dso != null)
			{
				renderViewer(body, dso);
			}
			else
			{
				renderHome(body);
			}

        } catch (RuntimeException e) {
            log.error(e.getMessage(), e);
		} catch (Exception e) {
			log.error(e.getMessage(), e);
        }

    }

    public void renderHome(Body body) throws WingException {

        Division home = body.addDivision("home", "primary repository");
        Division division = home.addDivision("stats", "secondary stats");
        division.setHead(T_head_title);
        /*
		try {

			StatisticsTable statisticsTable = new StatisticsTable(
					new StatisticsDataVisits());

			statisticsTable.setTitle(T_head_visits_month);
			statisticsTable.setId("tab1");

			DatasetTimeGenerator timeAxis = new DatasetTimeGenerator();
			timeAxis.setDateInterval("month", "-6", "+1");
			statisticsTable.addDatasetGenerator(timeAxis);

			addDisplayTable(division, statisticsTable);

		} catch (Exception e) {
			log.error("Error occurred while creating statistics for home page",
					e);
		}
		*/
        try {
            /** List of the top 10 items for the entire repository **/
            StatisticsListing statListing = new StatisticsListing( new StatisticsDataVisits());

            statListing.setTitle(T_head_visits_total);
            statListing.setId("list1");

            //Adding a new generator for our top 10 items without a name length delimiter
            DatasetDSpaceObjectGenerator dsoAxis = new DatasetDSpaceObjectGenerator();
            dsoAxis.addDsoChild(Constants.ITEM, 10, false, -1);
            statListing.addDatasetGenerator(dsoAxis);

            //Render the list as a table
            addDisplayListing(division, statListing);

        } catch (Exception e) {
            log.error("Error occurred while creating statistics for home page", e);
        }

    }

    public void renderViewer(Body body, DSpaceObject dso) throws WingException {

        String typeTextLower = dso.getTypeText().toLowerCase();
        Division home = body.addDivision(typeTextLower + "-home", "primary repository " + typeTextLower);

        // Build the collection viewer division.
        Division division = home.addDivision("stats", "secondary stats");
        division.setHead("Statistics for "+dso.getName());
        
        // Peters Form
        //addDateRangePicker(division);

        // Ryan's Form
        ReportGenerator reportGenerator = new ReportGenerator();
        reportGenerator.addReportGeneratorForm(division, ObjectModelHelper.getRequest(objectModel));
        dateStart = reportGenerator.getDateStart();
        dateEnd = reportGenerator.getDateEnd();

        // 1 - Number of Items in The Container (Community/Collection) (monthly and cumulative for the year)
        if(dso instanceof Collection || dso instanceof Community) {
            addItemsInContainer(dso, division);
        }

        // 2 - Number of Files in The Container (monthly and cumulative)
        if(dso instanceof Collection || dso instanceof Community) {
            addFilesInContainer(dso, division);
        }

        // 3 - Number of File Downloads in the container (monthly and cumulative)
        if(dso instanceof Collection || dso instanceof Community) {
            addFileDownloadsInContainer(dso, division);
        }

        // 4 - Unique visitors
        if(dso instanceof Collection || dso instanceof Community) {
            addUniqueVisitorsToContainer(dso, division);
        }

        // 5 - Visits to the Collection by Type of Domain (i.e. .com. .net. .org. .edu. .gov.)
        //@TODO Cannot search solr with a leading wildcard *.com., so need to add a reversed field to index .com.google.bot.12345
        Division visitsToDomain = division.addDivision("visits-by-domain");
        visitsToDomain.setHead("Visits to the Collection by type of domain");
        visitsToDomain.addPara("Not Yet Implemented! Need to change the data type of DNS to either reverse the field, or tokenize where dots are delimiter.");


        // 6 Visits to the collection by Geography
        addCountryViews(dso, division);


        // 6++IDEA: Map of the world hits
        //TODO Will implement Country Views chart as a Google Chart that feeds data from JSON solr data.

        // 7 Top 5 Downloads
        addTopDownloadsToContainer(dso, division);

        //
        // Default DSpace Standard Stats Queries Below
        //

        /*
        // Total Visits
        addVisitsTotal(dso, division);

        // Total Visits per Month
        addVisitsMonthly(dso, division);

        // Top Items
        addTopItems(dso, division);
        division.addPara().addXref(contextPath + "/usage-report?owningType=" + dso.getType() + "&owningID=" + dso.getID() + "&reportType=" + Constants.ITEM, "CSV of All Items");

        // Top Bitstreams
        addTopBitstreams(dso, division);
        division.addPara().addXref(contextPath + "/usage-report?owningType=" + dso.getType() + "&owningID=" + dso.getID() + "&reportType=" + Constants.BITSTREAM, "CSV of All Bitstreams");

        // File Visits (for Items)
        addBitstreamViewsToItem(dso, division);



        if(dso instanceof Collection) {
            addGrowthItemsPerYear(dso, division);
        }
        */
    }

    /**
     * Provide a list of the top 10 viewed Items if possible
     *
     * @param dso
     * @param division
     */
    public void addTopItems(DSpaceObject dso, Division division) {
        if ((dso instanceof org.dspace.content.Collection) || (dso instanceof org.dspace.content.Community)) {
            try {

                StatisticsTable statisticsTable = new StatisticsTable(new StatisticsDataVisits(dso));

                statisticsTable.setTitle("Top Items");
                statisticsTable.setId("tab1");

                DatasetTimeGenerator timeAxis = new DatasetTimeGenerator();
                timeAxis.setIncludeTotal(true);
                timeAxis.setDateInterval("day", "-14", "+1");
                statisticsTable.addDatasetGenerator(timeAxis);

                DatasetDSpaceObjectGenerator dsoAxis = new DatasetDSpaceObjectGenerator();
                dsoAxis.addDsoChild(org.dspace.core.Constants.ITEM, 100, false, -1);
                statisticsTable.addDatasetGenerator(dsoAxis);

                addDisplayTable(division, statisticsTable);

            } catch (Exception e) {
                log.error("Error occurred while creating top-items statistics for dso with ID: " + dso.getID()
                        + " and type " + dso.getType() + " and handle: " + dso.getHandle(), e);
            }

        }
    }

    /**
     * Provide a list of the top 10 viewed bitstreams if possible
     *
     * @param dso
     * @param division
     */
    public void addTopBitstreams(DSpaceObject dso, Division division) {
        if ((dso instanceof org.dspace.content.Collection) || (dso instanceof org.dspace.content.Community)) {
            try {

                StatisticsTable statisticsTable = new StatisticsTable(new StatisticsDataVisits(dso));

                statisticsTable.setTitle("Top Files");
                statisticsTable.setId("last-bit");

                DatasetTimeGenerator timeAxis = new DatasetTimeGenerator();
                timeAxis.setIncludeTotal(true);
                timeAxis.setDateInterval("day", "-21", "+1");
                statisticsTable.addDatasetGenerator(timeAxis);

                DatasetDSpaceObjectGenerator dsoAxis = new DatasetDSpaceObjectGenerator();
                dsoAxis.addDsoChild(Constants.BITSTREAM, 100, false, -1);
                statisticsTable.addDatasetGenerator(dsoAxis);

                addDisplayTable(division, statisticsTable);

            } catch (Exception e) {
                log.error("Error occured while creating top-bits statistics for dso with ID: " + dso.getID()
                        + " and type " + dso.getType() + " and handle: " + dso.getHandle(), e);
            }

        }
    }

    public void addVisitsTotal(DSpaceObject dso, Division division) {
        try {
            StatisticsListing statListing = new StatisticsListing(
                    new StatisticsDataVisits(dso));

            statListing.setTitle(T_head_visits_total);
            statListing.setId("list1");

            DatasetDSpaceObjectGenerator dsoAxis = new DatasetDSpaceObjectGenerator();
            dsoAxis.addDsoChild(dso.getType(), 10, false, -1);
            statListing.addDatasetGenerator(dsoAxis);

            addDisplayListing(division, statListing);

        } catch (Exception e) {
            log.error("Error occured while creating statistics for dso with ID: " + dso.getID()
                    + " and type " + dso.getType() + " and handle: " + dso.getHandle(), e);
        }
    }

    public void addVisitsMonthly(DSpaceObject dso, Division division) {
        try {

            StatisticsTable statisticsTable = new StatisticsTable(new StatisticsDataVisits(dso));

            statisticsTable.setTitle(T_head_visits_month);
            statisticsTable.setId("tab1");

            DatasetTimeGenerator timeAxis = new DatasetTimeGenerator();
            timeAxis.setDateInterval("month", "-6", "+1");
            statisticsTable.addDatasetGenerator(timeAxis);

            DatasetDSpaceObjectGenerator dsoAxis = new DatasetDSpaceObjectGenerator();
            dsoAxis.addDsoChild(dso.getType(), 10, false, -1);
            statisticsTable.addDatasetGenerator(dsoAxis);

            addDisplayTable(division, statisticsTable);

        } catch (Exception e) {
            log.error("Error occured while creating statistics for dso with ID: " + dso.getID()
                    + " and type " + dso.getType() + " and handle: " + dso.getHandle(), e);
        }
    }

    public void addBitstreamViewsToItem(DSpaceObject dso, Division division) {
        if (dso instanceof org.dspace.content.Item) {
            //Make sure our item has at least one bitstream
            org.dspace.content.Item item = (org.dspace.content.Item) dso;
            try {
                if (item.hasUploadedFiles()) {
                    StatisticsListing statsList = new StatisticsListing(new StatisticsDataVisits(dso));

                    statsList.setTitle(T_head_visits_bitstream);
                    statsList.setId("list-bit");

                    DatasetDSpaceObjectGenerator dsoAxis = new DatasetDSpaceObjectGenerator();
                    dsoAxis.addDsoChild(Constants.BITSTREAM, 10, false, -1);
                    statsList.addDatasetGenerator(dsoAxis);

                    addDisplayListing(division, statsList);
                }
            } catch (Exception e) {
                log.error("Error occured while creating statistics for dso with ID: " + dso.getID()
                        + " and type " + dso.getType() + " and handle: " + dso.getHandle(), e);
            }
        }

    }

    /**
     * Only call this on a container object (collection or community).
     * @param dso
     * @param division
     */
    public void addItemsInContainer(DSpaceObject dso, Division division) {
        // Must be either collection or community.
        if(!(dso instanceof Collection || dso instanceof Community)) {
            return;
        }
        
        String typeTextLower = dso.getTypeText().toLowerCase();

        String querySpecifyContainer = "SELECT to_char(date_trunc('month', t1.ts), 'YYYY-MM') AS yearmo, count(*) as countitem " +
                "FROM ( SELECT to_timestamp(text_value, 'YYYY-MM-DD') AS ts FROM metadatavalue, item, " +
                typeTextLower + "2item " +
                "WHERE metadata_field_id = 12 AND metadatavalue.item_id = item.item_id AND item.in_archive=true AND "+
                typeTextLower + "2item.item_id = item.item_id AND "+
                typeTextLower + "2item." + typeTextLower +"_id = ? ";

        if (dateStart != null) {
            String start = dateFormat.format(dateStart);
            querySpecifyContainer += "AND metadatavalue.text_value > '"+start+"'";
        }
        if(dateEnd != null) {
            String end = dateFormat.format(dateEnd);
            querySpecifyContainer += " AND metadatavalue.text_value < '"+end+"' ";
        }

        querySpecifyContainer += ") t1 GROUP BY date_trunc('month', t1.ts) order by yearmo asc";
        
        try {
            TableRowIterator tri;
            tri = DatabaseManager.query(context, querySpecifyContainer, dso.getID());

            java.util.List<TableRow> tableRowList = tri.toList();
            
            Integer[][] monthlyDataGrid = convertTableRowListToIntegerGrid(tableRowList, "yearmo", "countitem");
            displayAsGrid(division, monthlyDataGrid, "Number of Items Added to the " + StringUtils.capitalize(typeTextLower));
            
        } catch (SQLException e) {
            log.error(e.getMessage());  //To change body of catch statement use File | Settings | File Templates.
        } catch (WingException e) {
            log.error(e.getMessage());  //To change body of catch statement use File | Settings | File Templates.
        }
    }
    
    public Integer[][] convertTableRowListToIntegerGrid(java.util.List<TableRow> tableRowList, String dateColumn, String valueColumn) {
        if(tableRowList == null || tableRowList.size() == 0) {
            return null;
        }

        String yearmoStart = tableRowList.get(0).getStringColumn(dateColumn);
        Integer yearStart = Integer.valueOf(yearmoStart.split("-")[0]);
        String yearmoLast = tableRowList.get(tableRowList.size()-1).getStringColumn(dateColumn);
        Integer yearLast = Integer.valueOf(yearmoLast.split("-")[0]);
        //                    distinctBetween(2011, 2005)  = 7
        int distinctNumberOfYears = yearLast-yearStart+1;
        
        /**
         * monthlyDataGrid will hold all the years down, and the year number, as well as monthly values, plus total across.
         */
        Integer[][] monthlyDataGrid = new Integer[distinctNumberOfYears][14];
        for(int yearIndex = 0; yearIndex < distinctNumberOfYears; yearIndex++) {
            monthlyDataGrid[yearIndex][0] = yearStart+yearIndex;
            for(int dataColumnIndex = 1; dataColumnIndex < 14; dataColumnIndex++) {
                monthlyDataGrid[yearIndex][dataColumnIndex] = 0;
            }
        }



        for(TableRow monthRow: tableRowList) {
            String yearmo = monthRow.getStringColumn(dateColumn);

            String[] yearMonthSplit = yearmo.split("-");
            Integer currentYear = Integer.parseInt(yearMonthSplit[0]);
            Integer currentMonth = Integer.parseInt(yearMonthSplit[1]);

            long monthlyHits = monthRow.getLongColumn(valueColumn);

            monthlyDataGrid[currentYear-yearStart][currentMonth] = (int) monthlyHits;
        }

        // Fill first column with year name. And, fill in last column with cumulative annual total.
        for(int yearIndex = 0; yearIndex < distinctNumberOfYears; yearIndex++) {
            Integer yearCumulative=0;
            for(int monthIndex = 1; monthIndex <= 12; monthIndex++) {
                yearCumulative += monthlyDataGrid[yearIndex][monthIndex];
            }

            monthlyDataGrid[yearIndex][13] = yearCumulative;
        }
        return monthlyDataGrid;

    }

    /**
     * Standard conversion of input date, where input is "Month Year", i.e. "December 2011", i.e. "MMMM yyyy".
     * If you need a different date format, then use the other method.
     * @param objectCounts
     * @return
     * @throws ParseException
     */
    public Integer[][] convertObjectCountsToIntegerGrid(ObjectCount[] objectCounts) throws ParseException {
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM yyyy", Locale.getDefault());
        return convertObjectCountsToIntegerGrid(objectCounts, dateFormat);
    }
    
    public Integer[][] convertObjectCountsToIntegerGrid(ObjectCount[] objectCounts, SimpleDateFormat dateFormat) throws ParseException{
    
        Calendar calendar = Calendar.getInstance();



        Date date;

        date = dateFormat.parse(objectCounts[0].getValue());
        calendar.setTime(date);
        Integer yearStart = calendar.get(Calendar.YEAR);

        date = dateFormat.parse(objectCounts[objectCounts.length-1].getValue());
        calendar.setTime(date);
        Integer yearLast = calendar.get(Calendar.YEAR);

        int distinctNumberOfYears = yearLast-yearStart+1;

        /**
         * monthlyDataGrid will hold all the years down, and the year number, as well as monthly values, plus total across.
         */
        Integer[][] monthlyDataGrid = new Integer[distinctNumberOfYears][14];
        
        //Initialize the dataGrid with yearName and blanks
        for(int yearIndex = 0; yearIndex < distinctNumberOfYears; yearIndex++) {
            monthlyDataGrid[yearIndex][0] = yearStart+yearIndex;
            for(int dataColumnIndex = 1; dataColumnIndex < 14; dataColumnIndex++) {
                monthlyDataGrid[yearIndex][dataColumnIndex] = 0;
            }
        }

        //Fill in monthly values
        for(ObjectCount objectCountMonth: objectCounts) {
            date = dateFormat.parse(objectCountMonth.getValue());
            calendar.setTime(date);

            long monthlyHits = objectCountMonth.getCount();
            monthlyDataGrid[calendar.get(Calendar.YEAR)-yearStart][calendar.get(Calendar.MONTH)+1] = (int) monthlyHits;
        }

        // Fill in last column with cumulative annual total.
        for(int yearIndex = 0; yearIndex < distinctNumberOfYears; yearIndex++) {
            Integer yearCumulative=0;
            for(int monthIndex = 1; monthIndex <= 12; monthIndex++) {
                yearCumulative += monthlyDataGrid[yearIndex][monthIndex];
            }

            monthlyDataGrid[yearIndex][13] = yearCumulative;
        }
        return monthlyDataGrid;
    }
    
    public void displayAsGrid(Division division, Integer[][] monthlyDataGrid, String header) throws WingException {
        if(monthlyDataGrid == null || monthlyDataGrid.length == 0) {
            log.error("Grid has no data: "+ header);
            return;
        }

        Integer yearStart = monthlyDataGrid[0][0];
        Integer yearLast = monthlyDataGrid[monthlyDataGrid.length-1][0];
        int numberOfYears = yearLast-yearStart;

        Table gridTable = division.addTable("itemsInContainer-grid", numberOfYears+1, 14);
        gridTable.setHead(header);
        Row gridHeader = gridTable.addRow(Row.ROLE_HEADER);
        gridHeader.addCell().addContent("Year");
        gridHeader.addCell().addContent("JAN");
        gridHeader.addCell().addContent("FEB");
        gridHeader.addCell().addContent("MAR");
        gridHeader.addCell().addContent("APR");
        gridHeader.addCell().addContent("MAY");
        gridHeader.addCell().addContent("JUN");
        gridHeader.addCell().addContent("JUL");
        gridHeader.addCell().addContent("AUG");
        gridHeader.addCell().addContent("SEP");
        gridHeader.addCell().addContent("OCT");
        gridHeader.addCell().addContent("NOV");
        gridHeader.addCell().addContent("DEC");
        gridHeader.addCell().addContent("Total YR");

        for(int yearIndex=0; yearIndex < monthlyDataGrid.length; yearIndex++) {
            Row yearRow = gridTable.addRow();
            yearRow.addCell(Cell.ROLE_HEADER).addContent(monthlyDataGrid[yearIndex][0]);
            for(int yearContentIndex = 1; yearContentIndex<14; yearContentIndex++) {
                yearRow.addCell().addContent(monthlyDataGrid[yearIndex][yearContentIndex]);
            }
        }
    }
    
    public void displayAsTableRows(Division division, java.util.List<TableRow> tableRowList, String title) throws WingException {
        Table table = division.addTable("itemsInContainer", tableRowList.size()+1, 3);
        table.setHead(title);

        Row header = table.addRow(Row.ROLE_HEADER);
        header.addCell().addContent("Month");
        header.addCell().addContent("Added During Month");
        header.addCell().addContent("Total Cumulative");

        int cumulativeHits = 0;
        for(TableRow row : tableRowList) {
            Row htmlRow = table.addRow(Row.ROLE_DATA);

            String yearmo = row.getStringColumn("yearmo");
            htmlRow.addCell().addContent(yearmo);

            long monthlyHits = row.getLongColumn("countitem");
            htmlRow.addCell().addContent(""+monthlyHits);

            cumulativeHits += monthlyHits;
            htmlRow.addCell().addContent(""+cumulativeHits);
        }
    }

    public void addFilesInContainer(DSpaceObject dso, Division division) {
        // Must be either collection or community.
        if(!(dso instanceof Collection || dso instanceof Community)) {
            return;
        }
        String typeTextLower = dso.getTypeText().toLowerCase();

        String querySpecifyContainer = "SELECT to_char(date_trunc('month', t1.ts), 'YYYY-MM') AS yearmo, count(*) as countitem " +
                "FROM ( SELECT to_timestamp(text_value, 'YYYY-MM-DD') AS ts FROM metadatavalue, item, item2bundle, bundle, bundle2bitstream, " +
                typeTextLower + "2item " +
                "WHERE metadata_field_id = 12 AND metadatavalue.item_id = item.item_id AND item.in_archive=true AND " +
                    "item2bundle.bundle_id = bundle.bundle_id AND item2bundle.item_id = item.item_id AND bundle.bundle_id = bundle2bitstream.bundle_id AND bundle.\"name\" = 'ORIGINAL' AND "+
                typeTextLower + "2item.item_id = item.item_id AND "+
                typeTextLower + "2item."+typeTextLower+"_id = ? ";

        if (dateStart != null) {
            String start = dateFormat.format(dateStart);
            querySpecifyContainer += "AND metadatavalue.text_value > '"+start+"'";
        }
        if(dateEnd != null) {
            String end = dateFormat.format(dateEnd);
            querySpecifyContainer += " AND metadatavalue.text_value < '"+end+"' ";
        }

        querySpecifyContainer += ") t1 GROUP BY date_trunc('month', t1.ts) order by yearmo asc";

        try {
            TableRowIterator tri = DatabaseManager.query(context, querySpecifyContainer, dso.getID());

            java.util.List<TableRow> tableRowList = tri.toList();

            Integer[][] monthlyDataGrid = convertTableRowListToIntegerGrid(tableRowList, "yearmo", "countitem");
            
            displayAsGrid(division, monthlyDataGrid, "Number of Files in the "+StringUtils.capitalize(typeTextLower));
            //displayAsTableRows(division, tableRowList, "Number of Files in the "+getTypeAsString(dso));

        } catch (SQLException e) {
            log.error(e.getMessage());  //To change body of catch statement use File | Settings | File Templates.
        } catch (WingException e) {
            log.error(e.getMessage());  //To change body of catch statement use File | Settings | File Templates.
        }
    }

    public void addFileDownloadsInContainer(DSpaceObject dso, Division division) {
        // Must be either collection or community.
        if(!(dso instanceof Collection || dso instanceof Community)) {
            return;
        }

        String monthStart;
        if(dateStart != null) {
            monthStart = dateFormat.format(dateStart) + "T00:00:00.000Z";
        }   else {
            // In our situation, we have no usage statistics before Jan 1, 2008.
            monthStart = "2008-01-01T00:00:00.000Z";
        }
        
        String monthEnd;
        if(dateEnd != null) {
            monthEnd = dateFormat.format(dateEnd) + "T23:59:59.999Z";
        }   else {
            Calendar calendar = Calendar.getInstance();
            calendar.add(Calendar.MONTH, -1);
            Integer humanMonthNumber = calendar.get(Calendar.MONTH)+1;
            
            monthEnd =  calendar.get(Calendar.YEAR) + "-" + humanMonthNumber + "-" + calendar.getActualMaximum(Calendar.DAY_OF_MONTH)   + "T23:59:59.999Z";
        }
 

        String query = "type:0 AND -isBot:true AND "
                + ((dso instanceof Collection) ? "owningColl:" : "owningComm:")
                + dso.getID();

        log.info("addFileDownloadsInContainer Query: "+query);
        log.info("addFileDownloadsInContainer monthEnd:" + monthEnd);

        try {
            ObjectCount[] objectCounts = SolrLogger.queryFacetDate(query, "", -1, "MONTH", monthStart, monthEnd, false);

            Integer[][] monthlyDataGrid = convertObjectCountsToIntegerGrid(objectCounts);
            displayAsGrid(division, monthlyDataGrid, "Number of File Downloads in the " + StringUtils.capitalize(dso.getTypeText().toLowerCase()));

        } catch (SolrServerException e) {
            log.error("addFileDownloadsInContainer Solr Query Failed: " + e.getMessage());
        } catch (WingException e) {
            log.error("addFileDownloadsInContainer WingException: " + e.getMessage());
        } catch (ParseException e) {
            log.error(e.getMessage());
        }
    }

    public void addUniqueVisitorsToContainer(DSpaceObject dso, Division division) {
        // Must be either collection or community.
        if(!(dso instanceof Collection || dso instanceof Community)) {
            return;
        }

        try {
            GregorianCalendar startCalendar = new GregorianCalendar();

            if(dateStart != null) {
                startCalendar.setTime(dateStart);
            }   else {
                // In our situation, we have no usage statistics before Jan 1, 2008.
                startCalendar.set(2008, Calendar.JANUARY, 1, 0, 0, 0);
            }

            Calendar endCalendar = Calendar.getInstance();

            if(dateEnd != null) {
                endCalendar.setTime(dateEnd);
            }   else {
                endCalendar.add(Calendar.MONTH, -1);
            }

            ArrayList<ObjectCount> objectCountArrayList = new ArrayList<ObjectCount>();

            while(startCalendar.before(endCalendar)) {
                Integer humanMonthNumber = startCalendar.get(Calendar.MONTH)+1;

                String monthStart = startCalendar.get(Calendar.YEAR) + "-" + humanMonthNumber + "-" + startCalendar.getActualMinimum(Calendar.DAY_OF_MONTH)   + "T00:00:00.000Z";
                String monthEnd =  startCalendar.get(Calendar.YEAR) + "-" + humanMonthNumber + "-" + startCalendar.getActualMaximum(Calendar.DAY_OF_MONTH)   + "T23:59:59.999Z";

                String query = "type:0 AND -isBot:true AND time:[" + monthStart + " TO " + monthEnd + "]"
                    + ((dso instanceof Collection) ? "owningColl:" : "owningComm:")
                    + dso.getID();

                ObjectCount[] objectCounts = SolrLogger.queryFacetField(query, "", "ip", -1, true, null);

                if(objectCounts != null && objectCounts.length > 0) {
                    ObjectCount uniquesMonth = new ObjectCount();
                    uniquesMonth.setValue(monthStart);
                    uniquesMonth.setCount(objectCounts.length);
                    objectCountArrayList.add(uniquesMonth);
                }

                //Then Increment the lower month
                startCalendar.add(Calendar.MONTH, 1);
            }

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-M-d", Locale.getDefault());
            Integer[][] monthlyDataGrid = convertObjectCountsToIntegerGrid(objectCountArrayList.toArray(new ObjectCount[objectCountArrayList.size()]), dateFormat);
            displayAsGrid(division, monthlyDataGrid, "Number of Unique Visitors to the " + StringUtils.capitalize(dso.getTypeText().toLowerCase()));

        } catch (SolrServerException e) {
            log.error("addUniqueVisitorsToContainer Solr Query Failed: " + e.getMessage());
        } catch (WingException e) {
            log.error("addUniqueVisitorsToContainer WingException: " + e.getMessage());
        } catch (ParseException e) {
            log.error(e.getMessage());
        }

    }

    public void addGrowthItemsPerYear(DSpaceObject dso, Division division) {
        Collection collection = (Collection) dso;
        try {
            TableRowIterator yearCountIterator = collection.getItemsAvailablePerYear();
            java.util.List<TableRow> yearCountList = yearCountIterator.toList();
            Table table = division.addTable("YearCounts", yearCountList.size(), 2);
            table.setHead("Item Growth Per Year");
            Row headerRow = table.addRow(Row.ROLE_HEADER);
            headerRow.addCell().addContent("Year");
            headerRow.addCell().addContent("Count");
            //add cumulative

            for(TableRow row : yearCountList) {
                Row dataRow = table.addRow(Row.ROLE_DATA);

                Double year =  row.getDoubleColumn("year");
                dataRow.addCellContent(year.toString());

                String countString = row.getStringColumn("count");
                dataRow.addCellContent(countString);
            }

        } catch (SQLException e) {
            log.error(e.getMessage());  //To change body of catch statement use File | Settings | File Templates.
        } catch (WingException e) {
            log.error(e.getMessage());
        }


    }

    public void addCountryViews(DSpaceObject dso, Division division) {
        try {
            StatisticsListing statListing = new StatisticsListing(new StatisticsDataVisits(dso));

            statListing.setTitle(T_head_visits_countries);
            statListing.setId("list2");

//            DatasetDSpaceObjectGenerator dsoAxis = new DatasetDSpaceObjectGenerator();
//            dsoAxis.addDsoChild(dso.getType(), 10, false, -1);

            DatasetTypeGenerator typeAxis = new DatasetTypeGenerator();
            typeAxis.setType("countryCode");
            typeAxis.setMax(10);
            statListing.addDatasetGenerator(typeAxis);

            addDisplayListing(division, statListing);
        } catch (Exception e) {
            log.error("Error occurred while creating statistics for dso with ID: " + dso.getID()
                    + " and type " + dso.getType() + " and handle: " + dso.getHandle(), e);
        }

    }

    /**
     * Get top downloads for the past month.
     * @param dso
     * @param division
     */
    public void addTopDownloadsToContainer(DSpaceObject dso, Division division) {
        // Must be either collection or community.
        if(!(dso instanceof Collection || dso instanceof Community)) {
            return;
        }

        String monthStart, monthEnd;
        if(dateStart != null && dateEnd != null) {
            monthStart = dateFormat.format(dateStart) + "T00:00:00.000Z";
            monthEnd = dateFormat.format(dateEnd) + "T23:59:59.999Z";
            
        } else {
            Calendar calendar = Calendar.getInstance();
            calendar.add(Calendar.MONTH, -1);
            Integer humanMonthNumber = calendar.get(Calendar.MONTH)+1;

            // We have a hard-limit to our stats Data of Jan 1, 2008. So locally we can start 1/1/2008
            // 2011-08-01T00:00:00.000Z TO 2011-08-31T23:59:59.999Z
            monthStart = calendar.get(Calendar.YEAR) + "-" + humanMonthNumber + "-" + calendar.getActualMinimum(Calendar.DAY_OF_MONTH)   + "T00:00:00.000Z";
            monthEnd =  calendar.get(Calendar.YEAR) + "-" + humanMonthNumber + "-" + calendar.getActualMaximum(Calendar.DAY_OF_MONTH)   + "T23:59:59.999Z";
        }
        

        String query = "type:0 AND -isBot:true AND "
                + ((dso instanceof Collection) ? "owningColl:" : "owningComm:")
                + dso.getID();

        log.info("addFileDownloadsInContainer Query: "+query);
        log.info("addFileDownloadsInContainer monthEnd:" + monthEnd);

        try {
            ObjectCount[] objectCounts = SolrLogger.queryFacetField(query, "time:["+monthStart+" TO "+monthEnd+"]", "id", 10, false, null);
            displayTopDownloadsGrid(objectCounts, division, dso);


        } catch (SolrServerException e) {
            log.error("addFileDownloadsInContainer Solr Query Failed: " + e.getMessage());
        } catch (WingException e) {
            log.error("addFileDownloadsInContainer WingException: " + e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
    }
    
    public void displayTopDownloadsGrid(ObjectCount[] objectCounts, Division division, DSpaceObject dso) throws WingException, SQLException {
        Table table = division.addTable("topDownloads", objectCounts.length, 2);
        table.setHead("Top Downloads to "+StringUtils.capitalize(dso.getTypeText().toLowerCase()));
        Row header = table.addRow(Row.ROLE_HEADER);
        header.addCell(Row.ROLE_HEADER).addContent("Title");
        header.addCell(Row.ROLE_HEADER).addContent("Creator");
        header.addCell(Row.ROLE_HEADER).addContent("Publisher");
        header.addCell(Row.ROLE_HEADER).addContent("Date");
        header.addCell(Row.ROLE_HEADER).addContent("# DL");

        for(ObjectCount object : objectCounts) {
            Row bodyRow = table.addRow(Row.ROLE_DATA);
            Bitstream bitstream = Bitstream.find(context, Integer.parseInt(object.getValue()));
            DSpaceObject parentDSO = bitstream.getParentObject();
            if (parentDSO instanceof org.dspace.content.Item) {
                Item item = (Item) parentDSO;
                bodyRow.addCell().addXref(contextPath + "/handle/" + item.getHandle(), item.getName());

                DCValue[] creators = item.getMetadata("dc.creator");
                if(creators != null && creators.length > 0) {
                    bodyRow.addCell().addContent(creators[0].value);
                } else {
                    bodyRow.addCell();
                }

                DCValue[] publishers = item.getMetadata("dc.publisher");
                if(publishers != null && publishers.length > 0) {
                    bodyRow.addCell().addContent(publishers[0].value);
                } else {
                    bodyRow.addCell();
                }

                DCValue[] dateIssued = item.getMetadata("dc.date.issued");
                if(dateIssued != null && dateIssued.length > 0) {
                    bodyRow.addCell().addContent(dateIssued[0].value);
                } else {
                    bodyRow.addCell();
                }

                bodyRow.addCell("downloads", Cell.ROLE_DATA, "right").addContent(object.getCount() + "");
            }
        }
    }



    public void addCityViews(DSpaceObject dso, Division division) {
        try {
            StatisticsListing statListing = new StatisticsListing(new StatisticsDataVisits(dso));

            statListing.setTitle(T_head_visits_cities);
            statListing.setId("list3");

//            DatasetDSpaceObjectGenerator dsoAxis = new DatasetDSpaceObjectGenerator();
//            dsoAxis.addDsoChild(dso.getType(), 10, false, -1);

            DatasetTypeGenerator typeAxis = new DatasetTypeGenerator();
            typeAxis.setType("city");
            typeAxis.setMax(10);
            statListing.addDatasetGenerator(typeAxis);

            addDisplayListing(division, statListing);
        } catch (Exception e) {
            log.error("Error occurred while creating statistics for dso with ID: " + dso.getID()
                    + " and type " + dso.getType() + " and handle: " + dso.getHandle(), e);
        }
    }
    
    public void addDateRangePicker(Division division) throws WingException {
        Request request = ObjectModelHelper.getRequest(objectModel);

        Division search = division.addInteractiveDivision("choose-report", request.getRequestURI(), Division.METHOD_GET, "primary");
        search.setHead("Choose your Report Settings");

        org.dspace.app.xmlui.wing.element.List actionsList = search.addList("actions", "form");
        org.dspace.app.xmlui.wing.element.Item actionSelectItem = actionsList.addItem();

        Select startMonth = actionSelectItem.addSelect("startMonth");
        startMonth.addOption(false, "", "Choose Start Month");

        Select startYear = actionSelectItem.addSelect("startYear");
        startYear.addOption(false, "", "Choose Start Year");

        Select endMonth = actionSelectItem.addSelect("endMonth");
        endMonth.addOption(false, "", "Choose End Month");

        Select endYear = actionSelectItem.addSelect("endYear");
        endYear.addOption(false, "", "Choose End Year");
        
        for(int i = 1; i <=12; i++) {
            startMonth.addOption(false, String.valueOf(i), DCDate.getMonthName(i, Locale.getDefault()));
            endMonth.addOption(false, String.valueOf(i), DCDate.getMonthName(i, Locale.getDefault()));
        }
        


        for(Integer yearIndex = 2004; yearIndex <= DCDate.getCurrent().getYear(); yearIndex++) {
            startYear.addOption(false, yearIndex.toString(), yearIndex.toString());
            endYear.addOption(false, yearIndex.toString(), yearIndex.toString());
        }

        CheckBox reportCheckbox = actionSelectItem.addCheckBox("reportsToInclude");
        reportCheckbox.addOption("numItems", "Number of Items");
        reportCheckbox.addOption("numFiles", "Number of Files");
        reportCheckbox.addOption("numFileDownloads", "Number of File Downloads");
        reportCheckbox.addOption("numUniqueVisitors", "Number of Unique Visitors");
        reportCheckbox.addOption("numTopDownloads", "Number of Top Downloads");

        
        Para buttons = search.addPara();
        buttons.addButton("submit_add").setValue("Create Report");
        
        String paramStartMonth = request.getParameter("startMonth");
        String paramStartYear = request.getParameter("startYear");
        String paramEndMonth = request.getParameter("endMonth");
        String paramEndYear = request.getParameter("endYear");
        
        if(paramStartMonth != null && paramStartMonth != "" && paramStartYear != null && paramStartYear != "" && paramEndMonth != null && paramEndMonth != ""  && paramEndYear != null && paramEndYear != "" ) {
            //TODO SAFE CHECK PARAMS
            //yearMonthStart = paramStartYear+"-"+paramStartMonth;
            //yearMonthEnd = paramEndYear+"-"+paramEndMonth;
        }


        String paramReportName = request.getParameter("reportsToInclude");
        if((paramReportName != null) && (paramReportName.contains("numItems"))) {
            search.addPara("Include Report: Number of Items");
        }

    }


    /**
     * Adds a table layout to the page
     *
     * @param mainDiv the div to add the table to
     * @param display
     * @throws SAXException
     * @throws WingException
     * @throws ParseException
     * @throws IOException
     * @throws SolrServerException
     * @throws SQLException
     */
    private void addDisplayTable(Division mainDiv, StatisticsTable display)
            throws SAXException, WingException, SQLException,
            SolrServerException, IOException, ParseException {

        String title = display.getTitle();

        Dataset dataset = display.getDataset();

        if (dataset == null) {
            /** activate dataset query */
            dataset = display.getDataset(context);
        }

        if (dataset != null) {

            String[][] matrix = dataset.getMatrixFormatted();

            /** Generate Table */
            Division wrapper = mainDiv.addDivision("tablewrapper");
            Table table = wrapper.addTable("list-table", 1, 1,
                    title == null ? "" : "tableWithTitle");
            if (title != null) {
                table.setHead(message(title));
            }

            /** Generate Header Row */
            Row headerRow = table.addRow();
            headerRow.addCell("spacer", Cell.ROLE_DATA, "labelcell");

            String[] cLabels = dataset.getColLabels().toArray(new String[0]);
            for (int row = 0; row < cLabels.length; row++) {
                Cell cell = headerRow.addCell(0 + "-" + row + "-h", Cell.ROLE_DATA, "labelcell");
                cell.addContent(cLabels[row]);
            }

            /** Generate Table Body */
            for (int row = 0; row < matrix.length; row++) {
                Row valListRow = table.addRow();

                /** Add Row Title */
                valListRow.addCell("" + row, Cell.ROLE_DATA, "labelcell").
                        addXref(dataset.getRowLabelsAttrs().get(row).get("url"), dataset.getRowLabels().get(row));

                /** Add Rest of Row */
                for (int col = 0; col < matrix[row].length; col++) {
                    Cell cell = valListRow.addCell(row + "-" + col, Cell.ROLE_DATA, "datacell");
                    cell.addContent(matrix[row][col]);
                }
            }
        }

    }

    private void addDisplayListing(Division mainDiv, StatisticsListing display) throws SAXException, WingException,
            SQLException, SolrServerException, IOException, ParseException {

        String title = display.getTitle();

        Dataset dataset = display.getDataset();

        if (dataset == null) {
            /** activate dataset query */
            dataset = display.getDataset(context);
        }

        if (dataset != null) {

            String[][] matrix = dataset.getMatrixFormatted();

            // String[] rLabels = dataset.getRowLabels().toArray(new String[0]);

            Table table = mainDiv.addTable("list-table", matrix.length, 2,
                    title == null ? "" : "tableWithTitle");
            if (title != null) {
                table.setHead(message(title));
            }

            Row headerRow = table.addRow();

            headerRow.addCell("", Cell.ROLE_DATA, "labelcell");

            headerRow.addCell("", Cell.ROLE_DATA, "labelcell").addContent(message(T_head_visits_views));

            /** Generate Table Body */
            for (int col = 0; col < matrix[0].length; col++) {
                Row valListRow = table.addRow();

                Cell catCell = valListRow.addCell(col + "1", Cell.ROLE_DATA, "labelcell");
                catCell.addContent(dataset.getColLabels().get(col));

                Cell valCell = valListRow.addCell(col + "2", Cell.ROLE_DATA, "datacell");
                valCell.addContent(matrix[0][col]);

            }

            if (!"".equals(display.getCss())) {
                List attrlist = mainDiv.addList("divattrs");
                attrlist.addItem("style", display.getCss());
            }

        }

    }
}