package org.dspace.app.xmlui.aspect.artifactbrowser;


import au.com.bytecode.opencsv.CSVWriter;
import org.apache.log4j.Hierarchy;
import org.apache.log4j.Logger;
import org.apache.solr.client.solrj.SolrServerException;
import org.dspace.content.*;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.statistics.ObjectCount;
import org.dspace.statistics.SolrLogger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Exporting Community and hierarchy in CSV format
 */
public class HierarchyInfo extends HttpServlet
{
    protected static final Logger log = Logger.getLogger(HierarchyInfo.class);

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/csv; encoding='UTF-8'");
        response.setStatus(HttpServletResponse.SC_OK);
        response.setHeader("Content-Disposition", "attachment; filename=hierarchy-info.csv") ;
        CSVWriter writer = new CSVWriter(response.getWriter());

        String[] firstRow = initHierarchyLine();
        writer.writeNext(firstRow);

        try {
            Context context = new Context();
            Community[] topCommunities = Community.findAllTop(context);
            String[] rowString = new String[Hierarchy.values().length];

            for(Community community : topCommunities) {
                addCommunityHierarchy(community, 0, writer, rowString);
            }

        } catch (SQLException e) {
            log.error(e.getMessage());
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        writer.close();
    }

    protected void addCommunityHierarchy(Community community, Integer communityDepth, CSVWriter csvWriter, String[] rowString) throws SQLException {
        rowString[communityDepth] = community.getName();
        rowString = cleanHierarchyLine(rowString, communityDepth);

        //Get my collections and add to writer
        Collection[] collections = community.getCollections();
        for(Collection collection : collections) {
            writeCollection(collection, csvWriter, rowString);
        }

        //Get my subcommunities and recurse
        Community[] subCommunities = community.getSubcommunities();
        for(Community subCommunity : subCommunities) {
            addCommunityHierarchy(subCommunity, communityDepth+1, csvWriter, rowString);
        }



    }

    protected void writeCollection(Collection collection, CSVWriter csvWriter, String[] rowString) {
        rowString[Hierarchy.Collection.ordinal()] = collection.getName();
        try {
            rowString[Hierarchy.NumItems.ordinal()] = String.valueOf(collection.countItems());
            rowString[Hierarchy.NumBitstreams.ordinal()]=String.valueOf(collection.countBitstreams("ORIGINAL"));


            String childrenOfCollectionQuery = "owningColl:" + collection.getID();
            //http://localhost:8080/solr/statistics/select?q=owningColl:1379&facet=true&facet.field=type&rows=0

            ObjectCount[] objectCounts = new ObjectCount[0];
            try {
                objectCounts = SolrLogger.queryFacetField(childrenOfCollectionQuery, "", "type", 10, true, null);
                for(ObjectCount facetResult : objectCounts) {
                    log.info("Value for collection:"+collection.getID() + " is = " + facetResult.getValue() + " and count =" + facetResult.getCount());
                    if(facetResult.getValue().equals("2")) {
                        rowString[Hierarchy.ItemViews.ordinal()] = String.valueOf(facetResult.getCount());
                    } else if(facetResult.getValue().equals("0")) {
                        rowString[Hierarchy.BitstreamViews.ordinal()] = String.valueOf(facetResult.getCount());
                    }


                    // objectCounts[0].getValue() == 0
                    // objectCounts[0].getCount() == 10703
                }

            } catch (SolrServerException e) {
                log.error("Visiting Bit and Item Views query failed:" + e.getMessage());
            }


            // Give me collection views for this collection
            // ?q=id:941 AND type:3
            // 0 BITSTREAM
            // 1
            // 2 ITEM
            // 3 COLLECTION
            // 4 COMMUNITY

            try{

                String queryForThisId = "id:" + collection.getID() + " AND type:3";
                ObjectCount objectCount=SolrLogger.queryTotal(queryForThisId,"");
                rowString[Hierarchy.CollectionViews.ordinal()] = String.valueOf(objectCount.getCount());
            } catch (SolrServerException e) {
                log.error("visiting Collection Views query failed:" + e.getMessage());
            }


        } catch (SQLException e) {
            log.error("Error counting number of items for collection: "+collection.getName() + " -- " + collection.getHandle());
            rowString[Hierarchy.NumItems.ordinal()] = "Unknown";
        }
        csvWriter.writeNext(rowString);
    }

    /**
     * Create a String Array to write values for each field of our hierarchy report
     *  firstRow[0] = "Top Level community";
     *  ...
     *  firstRow[7] = "Number of Items";
     * @return
     */
    protected String[] initHierarchyLine(){
        String[] line = new String[Hierarchy.values().length];
        for(Hierarchy entry : Hierarchy.values()) {
            line[entry.ordinal()] = entry.toString();
        }
        return line;
    }

    /**
     * The hierarchy line can get dirty, so we need to clean it when we get to a new community.
     * The shape of the hierarchy line should be:
     * parent+, collection, stats
     * Where only parents in a position before the current depth remain untouched, the rest are cleared.
     * The statistics will get cleared each time.
     * @param hierarchyLine
     * @param depth
     * @return
     */
    protected String[] cleanHierarchyLine(String[] hierarchyLine, int depth) {
        Integer scrub = depth+1;

        // depth < scrub < collection.ordinal
        while((depth < scrub) && (scrub < Hierarchy.Collection.ordinal())) {
            hierarchyLine[scrub] = "";
            scrub++;
        }

        // Now clear out the stats... everything after collection
        scrub = Hierarchy.Collection.ordinal()+1;
        while(scrub < Hierarchy.values().length) {
            hierarchyLine[scrub] = "";
            scrub++;
        }

        return hierarchyLine;
    }

    protected enum Hierarchy {
        TopCommunity,
        SubCom1,
        SubCom2,
        SubCom3,
        Collection,
        CollectionViews,
        NumItems,
        ItemViews,
        NumBitstreams,
        BitstreamViews;
    }


}