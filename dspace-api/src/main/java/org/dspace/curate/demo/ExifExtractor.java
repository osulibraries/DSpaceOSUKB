/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.curate.demo;

import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.*;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.content.*;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;
import org.dspace.storage.bitstore.BitstreamStorageManager;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;

/**
 * ExifExtractor
 * -----------------
 * ExifExtractor extracts EXIF metadata from JPEG images.
 * This is a simplified version of my original "Extract GPS Coordinates" task which will
 * look for a list of exif tags specified in [dspace]/config/modules/exif.cfg, extract them
 * from the JPEG if they exist, and save them in the fields specified.
 *
 * Tags configured in exif.cfg should be all lowercase, and should contain underscores
 * in place of spaces (eg. "gps latitude" becomes "gps_latitude"):
 *
 * exif.tag.gps_latitude = dc.coverage.spatial
 * exif.tag.gps_longitude = dc.coverage.spatial
 *
 * @author Kim Shepherd
 */

@Distributive
public class ExifExtractor extends AbstractCurationTask
{
    private static final String PLUGIN_PREFIX = "exif";
    int status = Curator.CURATE_SKIP;
    private HashMap<String, String> tags;
    private boolean clearPreviousValues = false;
    Context c;

    private static Logger log = Logger.getLogger(ExifExtractor.class);

    @Override
    public void init(Curator curator, String taskId) throws IOException
    {
        super.init(curator, taskId);

        try {
            c = new Context();
            tags = new HashMap<String, String>();
            populateTagList();
            clearPreviousValues = ConfigurationManager.getBooleanProperty(PLUGIN_PREFIX, "exif.options.clearExistingMetadata", false);
        }
        catch(Exception e)
        {
            log.info(e.getLocalizedMessage());
        }
    }

    private void populateTagList()
    {
        String configPrefix = "exif.tag.";
        Enumeration pe = ConfigurationManager.propertyNames(PLUGIN_PREFIX);

        while(pe.hasMoreElements())
        {
            String key = (String)pe.nextElement();
            if(key.startsWith(configPrefix))
            {
                String tagName = StringUtils.substringAfter(key,configPrefix);
                String metadataField = ConfigurationManager.getProperty(PLUGIN_PREFIX, key);
                tags.put(tagName,  metadataField);
                report("Looking for " + tagName + " to copy to " + metadataField);
            }
        }
    }

    /**
     * Perform the curation task upon passed DSO
     *
     * @param dso the DSpace object
     * @throws java.io.IOException
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException
    {

        distribute(dso);
        cleanup();
        return Curator.CURATE_SUCCESS;
    }
    
    @Override
    protected void performItem(Item item) throws SQLException, IOException
    {
        for (Bundle bundle : item.getBundles("ORIGINAL"))
        {
            for (Bitstream bs : bundle.getBitstreams())
            {
                if(bs.getFormatDescription().equals("JPEG"))
                {
                    try {
                        Metadata md = ImageMetadataReader.readMetadata(new BufferedInputStream(BitstreamStorageManager.retrieve(c, bs.getID())));
                        Iterator mdi = md.getDirectoryIterator();

                        
                        while(mdi.hasNext()) {
                            Directory d = (Directory) mdi.next();
                            Iterator ti = d.getTagIterator();

                            String tagName = "";
                            String tagValue = "";
                            while (ti.hasNext()) {

                                Tag t = (Tag) ti.next();
                                tagName = t.getTagName().toLowerCase().replace(' ','_');
                                tagValue = t.getDescription();
                                if(tags.containsKey(tagName)) {
                                    String[] metadataField = StringUtils.split(tags.get(tagName), ".");
                                    if(metadataField.length > 2)
                                        updateItemMetadata(item, metadataField[0], metadataField[1], metadataField[2], tagValue);
                                    else if(metadataField.length == 2)
                                        updateItemMetadata(item, metadataField[0], metadataField[1], null, tagValue);
                                }
                            }
                        }

                    } catch(Exception e) {
                        log.info(e.getLocalizedMessage());
                        report(item.getHandle() + ": Error extracting EXIF: " + e.getLocalizedMessage());
                    }
                }
            }

        }

        try {
            item.update();
        }
        catch(Exception e) {
            log.info(e.getLocalizedMessage());
            report(item.getHandle() + ": An error occurred updating item metadata");
        }

    }

    private void updateItemMetadata(Item item, String schema, String element, String qualifier, String value)
    {
        try {
            if(clearPreviousValues)
            {
                item.clearMetadata(schema, element, qualifier, Item.ANY);
            }

            item.addMetadata(schema, element, qualifier, null, value);
            item.decache();
            item.update();
            c.commit();
            report(item.getHandle() + " added " + schema + "." + element + "." + qualifier + " = " + value);

        } catch(Exception e) {
            log.info(e.getLocalizedMessage());
            report(item.getHandle() + ": An error occurred updating " + schema + "." + element + "." + qualifier + ": " + value);
        }
    }

    private void cleanup() {
        try
        {
            c.complete();
        }
        catch(SQLException e)
        {
            log.info("Couldn't obtain context: " + e.getLocalizedMessage());
        }
    }
}