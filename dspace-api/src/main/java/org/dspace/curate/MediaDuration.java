package org.dspace.curate;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.dspace.content.DCValue;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.ConfigurationManager;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;

/**
 * Created by IntelliJ IDEA.
 * User: peterdietz
 * Date: 6/19/12
 * Time: 3:25 PM
 * To change this template use File | Settings | File Templates.
 */

public class MediaDuration extends AbstractCurationTask {
    private static Logger log = Logger.getLogger(MediaDuration.class);
    
    private static String defaultExternalMedia = "dc.source.uri";
    private static String externalSourceField;
    private static String tempDirectoryPath;
    
    public void init(Curator curator, String taskId) throws IOException
    {
        super.init(curator, taskId);
        externalSourceField = getDefaultedConfiguration("webui.feed.podcast.sourceuri", defaultExternalMedia);
        tempDirectoryPath = ConfigurationManager.getProperty("dspace.dir") + "/temp/";
    }
    
    @Override
    public int perform(DSpaceObject dso) throws IOException {
        if(dso instanceof Item) {
            Item item = (Item) dso;
            DCValue[] externalMedia = item.getMetadata(externalSourceField);
            //http://somepath.to/media.mp3
            
            String output = "";
            
            if(externalMedia != null && externalMedia.length > 0) {




                URL mediaURL = new URL(externalMedia[0].value);

                File localFile = new File(tempDirectoryPath + "some-downloaded-file");
                FileUtils.copyURLToFile(mediaURL, localFile);

                


                Process mp3InfoProcess = Runtime.getRuntime().exec("/opt/local/bin/mp3info -p \"%S\" " + localFile.getAbsolutePath());
                BufferedReader reader = new BufferedReader(new InputStreamReader(mp3InfoProcess.getInputStream()));


                //might / should only need one line.
                String line;
                for(line = reader.readLine(); line != null; line = reader.readLine()) {
                    output += line;
                }

                //stuff the value into the metadata field.
                //skip doing this step if metadata-field is already filled.
                //fix the output results, to actually display right.

                curator.setResult(taskId, output);


                return Curator.CURATE_SUCCESS;
            } else {
                return Curator.CURATE_SKIP;
            }
        } else {
            return Curator.CURATE_SKIP;
        }
    }

    // utility to get config property with default value when not set.
    private static String getDefaultedConfiguration(String key, String dfl)
    {
        String result = ConfigurationManager.getProperty(key);
        return (result == null) ? dfl : result;
    }
}
