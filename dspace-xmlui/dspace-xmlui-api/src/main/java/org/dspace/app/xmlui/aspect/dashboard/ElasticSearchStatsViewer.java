package org.dspace.app.xmlui.aspect.dashboard;

import edu.osu.library.dspace.statistics.ElasticSearchLogger;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.log4j.Logger;
import org.dspace.app.xmlui.aspect.statistics.ReportGenerator;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.*;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.client.Client;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.search.facet.FacetBuilders;
import org.elasticsearch.search.facet.terms.TermsFacet;

import java.util.*;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: peterdietz
 * Date: 3/7/12
 * Time: 11:54 AM
 * To change this template use File | Settings | File Templates.
 */
public class ElasticSearchStatsViewer extends AbstractDSpaceTransformer {
    private static Logger log = Logger.getLogger(ElasticSearchStatsViewer.class);
    
    public void addPageMeta(PageMeta pageMeta) throws WingException {
        pageMeta.addMetadata("title").addContent("Elastic Search Data Display");
    }
    
    public void addBody(Body body) throws WingException {
        Client client = ElasticSearchLogger.createElasticClient();
        try {
        Division division = body.addDivision("elastic-stats");
        division.setHead("Elastic Data Display");
        
        ReportGenerator reportGenerator = new ReportGenerator();
        reportGenerator.addReportGeneratorForm(division, ObjectModelHelper.getRequest(objectModel));
        Date dateStart = reportGenerator.getDateStart();
        Date dateEnd = reportGenerator.getDateEnd();

        SearchResponse resp = client.prepareSearch(ElasticSearchLogger.indexName)
                .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                .setQuery(QueryBuilders.matchAllQuery())
                .addFacet(FacetBuilders.termsFacet("facet1").field("type"))
                .execute()
                .actionGet();


        //division.addPara(resp.toString());

        SearchHits hits = resp.getHits();
        int numberHits = (int) hits.totalHits();

        division.addPara("Querying bitstreams for elastic, Took " + resp.tookInMillis() + " ms to get " + numberHits + " hits.");

        if(numberHits == 0) {
            return;
        }

        // Need to cast the facets to a TermsFacet so that we can get things like facet count. I think this is obscure.
        TermsFacet termsFacet = resp.getFacets().facet(TermsFacet.class, "facet1");
        List<? extends TermsFacet.Entry> termsFacetEntries = termsFacet.getEntries();

        Table facetTable = division.addTable("facettable", termsFacetEntries.size(), 10);
        Row facetTableHeaderRow = facetTable.addRow(Row.ROLE_HEADER);
        facetTableHeaderRow.addCell().addContent("Facet Name");
        facetTableHeaderRow.addCell().addContent("Count");
        
        for(TermsFacet.Entry facetEntry : termsFacetEntries) {
            Row row = facetTable.addRow();
            row.addCell().addContent(facetEntry.getTerm());
            row.addCell().addContent("" + facetEntry.getCount());
        }
                
        
        
        Table table = division.addTable("datatable", numberHits, 18);

        for(SearchHit hit : hits) {
            Map<String, Object> hitSource = hit.getSource();
            log.info(hitSource.size());
            Row thisRow = table.addRow();
            
            Set<Map.Entry<String, Object>> setHits = hitSource.entrySet();
            log.info("NumFields = "+setHits.size());
                    
            Iterator fields = setHits.iterator();
            while(fields.hasNext()) {
                Map.Entry thisEntry = (Map.Entry) fields.next();
                Object key = thisEntry.getKey();
                Object value = thisEntry.getValue();
                thisRow.addCell().addContent(value.toString());
                
            }

        }
        } finally {
            client.close();
        }
        
        /*TermQueryBuilder termQueryBuilder = new TermQueryBuilder("type", "BITSTREAM");

        ListenableActionFuture<SearchResponse> searchResponseListenableActionFuture = client
                .prepareSearch(ElasticSearchLogger.indexName)
                .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                .setQuery(termQueryBuilder.buildAsBytes())
                .setFrom(0).setSize(60).setExplain(true)
                .execute();
                */

        
    }
    
    
}
