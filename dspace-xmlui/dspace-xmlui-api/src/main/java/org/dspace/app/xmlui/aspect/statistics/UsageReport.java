package org.dspace.app.xmlui.aspect.statistics;

import au.com.bytecode.opencsv.CSVWriter;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.common.params.FacetParams;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Cell;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.Row;
import org.dspace.app.xmlui.wing.element.Table;
import org.dspace.content.*;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.statistics.ObjectCount;
import org.dspace.statistics.SolrLogger;

import javax.management.ObjectName;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Provides usage report of specified container, and specified type.
 * You'll probably get something like monthly downloads of bitstreams for a specified collectionID.
 */
public class UsageReport extends HttpServlet {
    protected static final Logger log = Logger.getLogger(UsageReport.class);

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/csv; encoding='UTF-8'");
        response.setStatus(HttpServletResponse.SC_OK);
        response.setHeader("Content-Disposition", "attachment; filename=usage-report.csv");

        CSVWriter writer = new CSVWriter(response.getWriter());

        // usage-report?owningType=dso.getType()&owningID=dso.getID()&reportType=Constants.{type}
        Integer owningType = Integer.parseInt(request.getParameter("owningType"));
        Integer owningID =   Integer.parseInt(request.getParameter("owningID"));
        Integer reportType = Integer.parseInt(request.getParameter("reportType"));

        try {
            Context context = new Context();

            DSpaceObject dso = DSpaceObject.find(context,owningType, owningID);
            addTypeDownloadsForOwningContainer(dso, writer, reportType);
        } catch (SQLException e) {
            log(e.getMessage());
        }
        writer.close();
    }

    /**
     * Get all hits to the specified DSO, that are of type specified.
     * @param parentDSO The parent container that has children resources that we are reporting
     * @param writer
     * @param reportType The type of the children to report on. Either Constants.BITSTREAM or Constants.ITEM
     * @throws SQLException
     */
    public void addTypeDownloadsForOwningContainer(DSpaceObject parentDSO, CSVWriter writer, Integer reportType) throws SQLException {
        // http://localhost:8080/solr/statistics/select?q=type:0+AND+owningComm:167&facet=true&facet.field=id&rows=0&facet.limit=-1&facet.mincount=1&facet.sort=count

        String[] headerRow = new String[8];
        switch(reportType) {
            case Constants.BITSTREAM:
                headerRow[0] = "bitstreamID";
                headerRow[1] = "bitstreamName";
                headerRow[2] = "bundleName";
                headerRow[3] = "Downloads";
                headerRow[4] = "ItemHandle";
                headerRow[5] = "ItemName";
                headerRow[6] = "CollectionHandle";
                headerRow[7] = "CollectionName";
                break;
            case Constants.ITEM:
                headerRow[0] = "itemID";
                headerRow[1] = "itemName";
                headerRow[2] = "handle";
                headerRow[3] = "Views";
                break;
        }
        writer.writeNext(headerRow);

        String query = "type:"+reportType;
        switch (parentDSO.getType()) {
            case Constants.COMMUNITY:
                query = query + " AND owningComm:"+parentDSO.getID();
                break;
            case Constants.COLLECTION:
                query = query + " AND owningColl:"+parentDSO.getID();
                break;
            case Constants.ITEM:
                query = query + " AND owningItem:"+parentDSO.getID();
                break;
        }

        Context context = new Context();
        ObjectCount[] objectCounts = new ObjectCount[0];
        try {
            objectCounts = SolrLogger.queryFacetField(query, "", "id", -1, false, null);

        } catch (SolrServerException e) {
            log.error("UsageReport query failed." + e.getMessage());
        }


        for(ObjectCount objectCount : objectCounts) {
            String[] row = new String[8];

            switch (reportType) {
                case Constants.BITSTREAM:
                    Integer bitstreamID = Integer.parseInt(objectCount.getValue());
                    Bitstream bitstream = Bitstream.find(context, bitstreamID);
                    row[0] = bitstreamID.toString();
                    row[1] = bitstream.getName();
                    row[2] = (bitstream.getBundles().length>0) ? bitstream.getBundles()[0].getName() : "unknown";
                    row[3] = String.valueOf(objectCount.getCount());

                    // Add additional information about the bitstream: owning Item, Collection
                    DSpaceObject bitstreamParentDSO = bitstream.getParentObject();
                    if(bitstreamParentDSO instanceof Item) {
                        Item parentItem = (Item) bitstreamParentDSO;
                        row[4] = parentItem.getHandle();
                        row[5] = parentItem.getName();
                        Collection[] owningCollections = parentItem.getCollections();
                        row[6] = "";
                        row[7] = "";
                        for(int i =0; i < owningCollections.length; i++) {
                            if(i>0) {
                                // Add a delimiter between multiple entries
                                row[6] += "||";
                                row[7] += "||";
                            }
                            row[6] += owningCollections[i].getHandle();
                            row[7] += owningCollections[i].getName();
                        }
                    }


                    break;
                case Constants.ITEM:
                    Integer itemID = Integer.parseInt(objectCount.getValue());
                    Item item = Item.find(context, itemID);
                    row[0] = itemID.toString();
                    row[1] = item.getName();
                    row[2] = item.getHandle();
                    row[3] = String.valueOf(objectCount.getCount());
                    //@TODO Add more context infor for item
            }

            writer.writeNext(row);
        }
    }


}
