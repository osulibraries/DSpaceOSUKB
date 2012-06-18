package org.dspace.app.util.syndicationmodule;

import com.sun.syndication.feed.module.Module;
import com.sun.syndication.io.ModuleGenerator;
import org.jdom.Element;
import org.jdom.Namespace;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * Created by IntelliJ IDEA.
 * User: peterdietz
 * Date: 6/18/12
 * Time: 3:55 PM
 * To change this template use File | Settings | File Templates.
 */
public class ItunesUModuleGenerator implements ModuleGenerator {
    private static final Namespace NAMESPACE = Namespace.getNamespace("itunesu", ItunesUModule.URI);
    private static final Set NAMESPACES;
    static {
        Set<Namespace> namespaces = new HashSet<Namespace>();
        namespaces.add(NAMESPACE);
        NAMESPACES = Collections.unmodifiableSet(namespaces);
    }
    
    @Override
    public String getNamespaceUri() {
        return ItunesUModule.URI;
    }

    @Override
    public Set getNamespaces() {
        return NAMESPACES;
    }

    //<itunesu:category itunesu:code="101104"/>

    @Override
    public void generate(Module module, Element element) {
        ItunesUModule itunesUModule = (ItunesUModule) module;

        if(itunesUModule.getCategoryCode() != null) {
            Element categoryCodeElement = new Element("category", NAMESPACE);
            categoryCodeElement.setAttribute("code", itunesUModule.getCategoryCode() + "", NAMESPACE);
            element.addContent(categoryCodeElement);
        }
    }
}
