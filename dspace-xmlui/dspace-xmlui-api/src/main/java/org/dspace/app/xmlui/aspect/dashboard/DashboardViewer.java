/*
 * DashboardViewer.java
 *
 * Version: $Revision$
 *
 * Date: $Date$
 *
 * Copyright (c) 2002, Hewlett-Packard Company and Massachusetts
 * Institute of Technology.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Hewlett-Packard Company nor the name of the
 * Massachusetts Institute of Technology nor the names of their
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

package org.dspace.app.xmlui.aspect.dashboard;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;

import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.response.FacetField;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.*;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.Collection;
import org.dspace.core.Constants;
import org.dspace.statistics.ObjectCount;
import org.dspace.statistics.SolrLogger;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;
import org.xml.sax.SAXException;




/**
 * Display a dashboard of information about the site.
 *
 *
 * @author Peter Dietz
 */
public class DashboardViewer extends AbstractDSpaceTransformer
{
    private static Logger log = Logger.getLogger(DashboardViewer.class);

    /**
     * Add a page title and trail links.
     */
    public void addPageMeta(PageMeta pageMeta) throws SAXException,
            WingException, UIException, SQLException, IOException,
            AuthorizeException
    {
        // Set the page title
        pageMeta.addMetadata("title").addContent("Dashboard");

        pageMeta.addTrailLink(contextPath + "/","KB Home");
        pageMeta.addTrailLink(contextPath + "/dashboard", "Dashboard");
    }

    /**
     * Add a community-browser division that includes refrences to community and
     * collection metadata.
     */
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException {
        Division division = body.addDivision("dashboard", "primary");
        division.setHead("Dashboard");
        division.addPara("A collection of statistical queries about the size and traffic of the KB.");

        Division search = body.addInteractiveDivision("choose-report", contextPath+"/dashboard", Division.METHOD_GET, "primary");
        search.setHead("Statistical Report Generation");
        org.dspace.app.xmlui.wing.element.List actionsList = search.addList("actions", "form");
        actionsList.addLabel("Label for action list");
        Item actionSelectItem = actionsList.addItem();
        Radio actionSelect = actionSelectItem.addRadio("report_name");
        actionSelect.setLabel("Choose a Report to View");
        actionSelect.addOption(false, "itemgrowth", "Number of Items in the Repository (Monthly) -- Google Chart");
        actionSelect.addOption(false, "commitems", "Items in Communities");
        actionSelect.addOption(false, "topDownloadsMonth", "Top Downloads for Month");

        Para buttons = search.addPara();
        buttons.addButton("submit_add").setValue("Create Report");

        Request request = ObjectModelHelper.getRequest(objectModel);
        String reportName = request.getParameter("report_name");

        if (StringUtils.isEmpty(reportName)) {
            reportName = "";
        }

        if(reportName.equals("itemgrowth"))
        {
            queryItemGrowthPerMonth(division);
        } else if(reportName.equals("commitems"))
        {
            queryNumberOfItemsPerComm(division);
        } else if (reportName.equals("topDownloadsMonth"))
        {
            addMonthlyTopDownloads(division);
        }


        Division exportLinks = division.addDivision("export-links");
        exportLinks.setHead("Additional Reports / Exports");
        exportLinks.addPara("Additional reports or queries that have been frequently run against the KB. Typically these reports are a .csv export of some query. " +
                "Instead of manually requesting, and then waiting for someone to execute the query, this is a bit of a self-service shortcut.");

        org.dspace.app.xmlui.wing.element.List links = exportLinks.addList("links");
        links.addItemXref(contextPath + "/growth-statistics?type="+Constants.ITEM, "Growth - Number of Items added to the Repository (Monthly)");
        links.addItemXref(contextPath + "/growth-statistics?type="+Constants.BITSTREAM, "Growth - Number of Bitstreams added to the Repository (Monthly)");
        links.addItemXref(contextPath + "/content-statistics",  "Size Totals #(Comms, Coll, Items, Bits, GBs)");
        links.addItemXref(contextPath + "/collection-info", "Collection List - Name, ID, Handle, #Items");
        links.addItemXref(contextPath + "/community-info", "Community List - Name, ID, Handle, #Items");
        links.addItemXref(contextPath + "/hierarchy-info", "Site Hierarchy - Comm > ... > Coll, #Items, #Bits, #Views, #Downloads");
    }

    /**
     * Adds Google charts visualizer of items in repository. It has a hidden table with the data too.
     * @param division
     * @throws SQLException
     * @throws WingException
     */
    private void queryItemGrowthPerMonth(Division division) throws SQLException, WingException
    {
        String query = "SELECT to_char(date_trunc('month', t1.ts), 'YYYY-MM') AS yearmo, count(*) as countitem " +
            "FROM ( SELECT to_timestamp(text_value, 'YYYY-MM-DD') AS ts FROM metadatavalue, item " +
            "WHERE metadata_field_id = 12 AND metadatavalue.item_id = item.item_id AND item.in_archive=true	) t1 " +
            "GROUP BY date_trunc('month', t1.ts) order by yearmo asc;";
        TableRowIterator tri = DatabaseManager.query(context, query);
        List itemStatRows = tri.toList();

        division.addDivision("chart_div");

        Division descriptionDivision = division.addDivision("description");
        descriptionDivision.addPara().addXref(contextPath + "/growth-statistics", "Download This Dataset as CSV");

        Table itemTable = division.addTable("items_added_monthly", itemStatRows.size(), 3);
        Row headerRow = itemTable.addRow(Row.ROLE_HEADER);
        headerRow.addCell().addContent("Date");
        headerRow.addCell().addContent("#Items Added");
        headerRow.addCell().addContent("Total #Items");
        Integer totalItems = 0;

        String html = "<script type='text/javascript' src='https://www.google.com/jsapi'></script>" +
            "<script type='text/javascript'>" +
            " google.load('visualization', '1', {'packages':['annotatedtimeline']});" +
            " google.setOnLoadCallback(drawChart);" +
            " function drawChart() {" +
            "  var data = new google.visualization.DataTable();" +
            "  data.addColumn('date', 'Date');" +
            "  data.addColumn('number', 'Items Added');" +
            "  data.addColumn('number', 'Total Items');" +
            "  data.addRows([";

        for(int i=0; i<itemStatRows.size();i++)
        {
            TableRow row = (TableRow) itemStatRows.get(i);
            log.debug(row.toString());
            String date = row.getStringColumn("yearmo");
            Long numItems = row.getLongColumn("countitem");
            totalItems += numItems.intValue();
            Row dataRow = itemTable.addRow();
            dataRow.addCell("date",Cell.ROLE_DATA,null).addContent(date);
            dataRow.addCell("items_added",Cell.ROLE_DATA,null).addContent(numItems.intValue());
            dataRow.addCell("items_total",Cell.ROLE_DATA, null).addContent(totalItems);

            String[] yearMonthSplit = date.split("-");
            if(i>0)
            {
                html = html + ",";
            }
            html = html + "[new Date("+yearMonthSplit[0]+", "+yearMonthSplit[1]+" ,1), "+numItems.toString()+", "+totalItems+"]";
        }
        html = html + "]); var chart = new google.visualization.AnnotatedTimeLine(document.getElementById('chart_div'));" +
            " chart.draw(data, {displayAnnotations: true}); }</script>";
        

        //division.addSimpleHTMLFragment(false, "&lt;![CDATA["+ html + " <div id='chart_div' style='width: 700px; height: 240px;'></div> ]]&gt;");
    }

    /**
     * In monthly intervals, find out the number that were in the KB.
     */
    private void queryNumberOfItemsPerComm(Division division) throws SQLException, WingException
    {
        String query = "SELECT to_char(date_trunc('month', t1.ts), 'YYYY-MM') AS yearmo, community_id," +
            "count(*) as numitems FROM 	(	SELECT to_timestamp(text_value, 'YYYY-MM-DD') AS ts, community2item.community_id " +
            "FROM metadatavalue, community2item, item	WHERE metadata_field_id = 12 AND community2item.item_id = metadatavalue.item_id " +
            "AND metadatavalue.item_id = item.item_id AND item.in_archive=true 	) t1 GROUP BY date_trunc('month', t1.ts), " +
            "community_id order by community_id asc, yearmo desc;";
        TableRowIterator tri = DatabaseManager.query(context, query);
        List itemStatRows = tri.toList();
        
        Table itemTable = division.addTable("items_added_per_comm", itemStatRows.size(), 3);
        Row headerRow = itemTable.addRow(Row.ROLE_HEADER);
        headerRow.addCell().addContent("YearMonth");
        headerRow.addCell().addContent("community_id");
        headerRow.addCell().addContent("num items");

        for(int i=0; i<itemStatRows.size();i++)
        {
            TableRow row = (TableRow) itemStatRows.get(i);
            log.debug(row.toString());
            String date = row.getStringColumn("yearmo");
            Integer community_id = row.getIntColumn("community_id");
            Long numItems = row.getLongColumn("numitems");
            Row dataRow = itemTable.addRow();
            dataRow.addCell().addContent(date);
            dataRow.addCell().addContent(community_id);

            dataRow.addCell().addContent(numItems.intValue());
        }
    }

    /**
     * Utility function to get the width of the date range the proper way. Is small performance cost though.
     * @param bitstreamID
     * @param dateType
     * @param rangeStart
     * @param rangeEnd
     * @return width of the date range
     * @throws SolrServerException
     */
    private int getWidthOfTimeFacet(int bitstreamID, String dateType, String rangeStart, String rangeEnd) throws SolrServerException
    {
        String query = "type: " + Constants.BITSTREAM + " AND id: " + bitstreamID;
        QueryResponse response = SolrLogger.queryWithDateFacet(query, dateType, rangeStart, rangeEnd);
        FacetField timeFacet = response.getFacetDate("time");
        return timeFacet.getValueCount();
    }

    /**
     * Adds the date faceted statistical hits to this bitstream to the page.
     * @param table DRI table to add results to
     * @param isHeader True if this bitstream only adds the dates to the header, False is it is adding the data for this BS.
     * @param bitstreamID Single bitstream ID to do a stats lookup on
     * @param dateType What increment of time we want to facet the results. Good choices are: DAY, MONTH
     * @param rangeStart Number of dateType ago to start the query. "-30" would be 30 Days/months ago.
     * @param rangeEnd Number of dateType ago/future to end the query. "+1" would include the current day/month in the endpoint.
     * @throws WingException, SolrServerException
     */
    public void getNumberOfVisitsToBitstream(Table table, boolean isHeader, int bitstreamID, String dateType, String rangeStart, String rangeEnd) throws WingException, SolrServerException, SQLException
    {
        String query = "type: " + Constants.BITSTREAM + " AND id: " + bitstreamID;
        QueryResponse response = SolrLogger.queryWithDateFacet(query, dateType, rangeStart, rangeEnd);
        FacetField timeFacet = response.getFacetDate("time");
        List<FacetField.Count> times = timeFacet.getValues();

        if(isHeader)
        {
            Row header = table.addRow(Row.ROLE_HEADER);
            header.addCell().addContent("Bitstream");
            for (int i = 0; i < times.size(); i++)
            {
                FacetField.Count dateCount = times.get(i);
                header.addCell().addContent(dateCount.getName());
            }
            header.addCell().addContent("Total for range");
        } else
        {
            Row dataRow = table.addRow(Row.ROLE_DATA);

            //Hopefully database accesses don't take TOO long
            Bitstream bs = Bitstream.find(context, bitstreamID);
            String handle = bs.getParentObject().getHandle();
            if (handle != null)
            {
                dataRow.addCell().addXref(contextPath+"/handle/"+handle, String.valueOf(bitstreamID));
            }
            else 
            {
                dataRow.addCell().addContent(bitstreamID);
            }

            long total = 0;
            for (int i = 0; i < times.size(); i++)
            {
                FacetField.Count dateCount = times.get(i);
                dataRow.addCell().addContent(String.valueOf(dateCount.getCount()));
                total = total + dateCount.getCount();
            }
            dataRow.addCell().addContent(String.valueOf(total));
        }
    }

    public void addMonthlyTopDownloads(Division division) throws WingException {
        Request request = ObjectModelHelper.getRequest(objectModel);
        String yearMonth = request.getParameter("yearMonth");
        Calendar calendar;
        if (StringUtils.isNotEmpty(yearMonth)) {
            // User Specified A Month   2011-08
            // Human years are something like 2005, ... same as computer
            // Human months are 1-12, computer months are 0-11. So we need to decrement input by 1.
            String[] dateChunk = yearMonth.split("-");
            Integer yearInput = Integer.valueOf(dateChunk[0]);
            Integer monthInput = Integer.valueOf(dateChunk[1])-1;
            calendar = new GregorianCalendar(yearInput, monthInput, 1);
        } else {
            // Show Previous Whole Month
            calendar = Calendar.getInstance();
            calendar.add(Calendar.MONTH, -1);
        }

        Integer humanMonthNumber = calendar.get(Calendar.MONTH)+1;

        // 2011-08-01T00:00:00.000Z TO 2011-08-31T23:59:59.999Z
        String monthRange = calendar.get(Calendar.YEAR) + "-" + humanMonthNumber + "-" + "01"                                               + "T00:00:00.000Z"
                 + " TO " + calendar.get(Calendar.YEAR) + "-" + humanMonthNumber + "-" + calendar.getActualMaximum(Calendar.DAY_OF_MONTH)   + "T23:59:59.999Z";

        String query = "type:0 AND owningComm:[0 TO 9999999] AND -dns:msnbot-* AND -isBot:true AND time:["+monthRange+"]";
        log.info("Top Downloads Query: "+query);
        ObjectCount[] objectCounts = new ObjectCount[0];
        try {
            objectCounts = SolrLogger.queryFacetField(query, "", "id", 50, true, null);

        } catch (SolrServerException e) {
            log.error("Top Downloads query failed.");
            log.error(e.getMessage());  //To change body of catch statement use File | Settings | File Templates.
        }

        Division downloadsDivision = division.addDivision("top-downloads", "primary");
        downloadsDivision.setHead("Top Bitstream Downloads for Month");
        downloadsDivision.addPara("The Top 50 Bitstream Downloads during the month of "+calendar.getDisplayName(Calendar.MONTH, Calendar.LONG, context.getCurrentLocale())+" "+calendar.get(Calendar.YEAR)+".");


        // Bitstream  | Bundle | Item Title | Collection Name | Number of Hits |

        Table table = downloadsDivision.addTable("topDownloads",objectCounts.length +1, 2);
        Row header = table.addRow(Row.ROLE_HEADER);
        header.addCell().addContent("Bitstream");
        header.addCell().addContent("Bundle");
        header.addCell().addContent("Item");
        header.addCell().addContent("Collection");
        header.addCell().addContent("Number of Hits");

        for(int i=0; i< objectCounts.length; i++)
        {
            Row row = table.addRow(Row.ROLE_DATA);
            Cell bitstreamCell = row.addCell();
            Cell bundleCell = row.addCell();
            Cell itemCell = row.addCell();
            Cell collectionCell = row.addCell();
            Cell hitsCell = row.addCell();

            String objectValue = objectCounts[i].getValue();
            if(objectValue.equals("total")) {
                bitstreamCell.addContent(objectValue);
            } else {
                Integer bitstreamID = Integer.parseInt(objectCounts[i].getValue());
                try {
                    Bitstream bitstream = Bitstream.find(context, bitstreamID);
                    bitstream.getName().length();
                    bitstreamCell.addXref(contextPath + "/bitstream/id/" + bitstreamID + "/" + bitstream.getName(), StringUtils.abbreviate(bitstream.getName(), 50));

                    Bundle[] bundles = bitstream.getBundles();
                    if(bundles != null && bundles.length > 0) {
                        Bundle bundle = bundles[0];
                        bundleCell.addContent(bundle.getName());

                        org.dspace.content.Item item = bundle.getItems()[0];
                        itemCell.addXref(contextPath + "/handle/" + item.getHandle(), StringUtils.abbreviate(item.getName(), 47));
                        Collection collection = item.getOwningCollection();
                        collectionCell.addXref(contextPath + "/handle/" + collection.getHandle(), StringUtils.abbreviate(collection.getName(), 47));
                    }
                } catch (SQLException e) {
                    log.error(e.getMessage());  //To change body of catch statement use File | Settings | File Templates.
                    bitstreamCell.addContent(bitstreamID);
                }
            }
            hitsCell.addContent((int) objectCounts[i].getCount());
        }
    }

    public void mimetypeReport(Division division) {
        String query = "SELECT \n" +
                "  bitstreamformatregistry.mimetype,\n" +
                "  count(*) as count\n" +
                "FROM \n" +
                "  public.bitstream, \n" +
                "  public.item, \n" +
                "  public.bundle, \n" +
                "  public.bundle2bitstream, \n" +
                "  public.item2bundle, \n" +
                "  public.bitstreamformatregistry\n" +
                "WHERE \n" +
                "  item.item_id = item2bundle.item_id AND\n" +
                "  bundle.bundle_id = bundle2bitstream.bundle_id AND\n" +
                "  bundle2bitstream.bitstream_id = bitstream.bitstream_id AND\n" +
                "  item2bundle.bundle_id = bundle.bundle_id AND\n" +
                "  bitstreamformatregistry.bitstream_format_id = bitstream.bitstream_format_id AND\n" +
                "  bundle.\"name\" = 'ORIGINAL' AND \n" +
                "  item.in_archive = true\n" +
                "Group by mimetype\n" +
                "order by count desc\n" +
                "\n" +
                "  ;";
    }
}
