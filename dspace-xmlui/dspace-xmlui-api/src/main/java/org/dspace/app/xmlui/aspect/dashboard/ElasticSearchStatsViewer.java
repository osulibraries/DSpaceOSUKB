package org.dspace.app.xmlui.aspect.dashboard;

import edu.osu.library.dspace.statistics.ElasticSearchLogger;
import org.apache.log4j.Logger;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.client.Client;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;

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
        Division division = body.addDivision("elastic-stats");
        division.setHead("Elastic Data Display");
        
        
        Client client = ElasticSearchLogger.createElasticClient();
        
        QueryBuilder queryBuilder = QueryBuilders.termQuery("city", "columbus");

        SearchResponse resp = client.prepareSearch(ElasticSearchLogger.indexName)
                .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                .setQuery(queryBuilder)
                .execute()
                .actionGet();


        division.addPara("Querying bitstreams for elastic, Took "+resp.tookInMillis() + " ms to get "+ resp.hits().totalHits() + " hits.");
        
        for(SearchHit hit : resp.hits().getHits()) {
            division.addPara("HIT_ID: " + hit.sourceAsString());
        }
        

        client.close();
        

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
