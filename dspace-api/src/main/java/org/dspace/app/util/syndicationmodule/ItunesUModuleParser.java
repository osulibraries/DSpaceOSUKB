package org.dspace.app.util.syndicationmodule;

import com.sun.syndication.feed.module.Module;
import com.sun.syndication.io.ModuleParser;
import org.jdom.Element;
import org.jdom.Namespace;

/**
 * Created by IntelliJ IDEA.
 * User: peterdietz
 * Date: 6/18/12
 * Time: 3:55 PM
 * To change this template use File | Settings | File Templates.
 */
public class ItunesUModuleParser implements ModuleParser {
    
    @Override
    public String getNamespaceUri() {
        return ItunesUModule.URI;
    }

    //<itunesu:category itunesu:code="101104"/>

    @Override
    public Module parse(Element element) {
        Namespace itunesUNamespace = Namespace.getNamespace(ItunesUModule.URI);
        ItunesUModule itunesUModule = new ItunesUModuleImpl();

        if(element.getNamespace().equals(itunesUNamespace)) {
            if(element.getName().equals("category")) {
                itunesUModule.setCategoryCode(Integer.valueOf(element.getAttributeValue("code", itunesUNamespace)));
            }
        }

        return itunesUModule;
    }
}
