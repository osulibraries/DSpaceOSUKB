package org.dspace.app.util.syndicationmodule;

import com.sun.syndication.feed.module.Module;

/**
 * Created by IntelliJ IDEA.
 * User: peterdietz
 * Date: 6/18/12
 * Time: 3:54 PM
 * To change this template use File | Settings | File Templates.
 */
public interface ItunesUModule extends Module {
    public static final String URI = "http://www.itunesu.com/feed";
    //<itunesu:category itunesu:code="101104"/>
    
    public Integer getCategoryCode();
    public void setCategoryCode(Integer categoryCode);
}
