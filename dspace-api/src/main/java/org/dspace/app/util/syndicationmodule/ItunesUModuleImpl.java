package org.dspace.app.util.syndicationmodule;

import com.sun.syndication.feed.module.ModuleImpl;

/**
 * Created by IntelliJ IDEA.
 * User: peterdietz
 * Date: 6/18/12
 * Time: 3:55 PM
 * To change this template use File | Settings | File Templates.
 */
public class ItunesUModuleImpl extends ModuleImpl implements ItunesUModule{
    private static final long serialVersionUID = -8275118704842545845L;
    
    private Integer categoryCode;
    
    public ItunesUModuleImpl() {
        super(ItunesUModule.class, ItunesUModule.URI);
    }
    
    public void copyFrom(Object obj) {
        ItunesUModule module = (ItunesUModule) obj;
        this.setCategoryCode(module.getCategoryCode());
    }
    
    public Class getInterface() {
        return ItunesUModule.class;
    }

    public Integer getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(Integer categoryCode) {
        this.categoryCode = categoryCode;
    }
}
