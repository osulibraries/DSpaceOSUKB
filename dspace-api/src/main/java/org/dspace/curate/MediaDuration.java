package org.dspace.curate;

import com.sun.syndication.feed.module.itunes.types.Duration;
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
            
            if(externalMedia != null && externalMedia.length > 0) {

                //skip doing this step if metadata-field is already filled.
                DCValue[] formatExtentMetadata = item.getMetadata("dc.format.extent");
                if(formatExtentMetadata != null && formatExtentMetadata.length > 0) {
                    curator.setResult(taskId, "Value for dc.format.extent already present.");
                    return Curator.CURATE_SKIP;
                }

                URL mediaURL = new URL(externalMedia[0].value);

                File localFile = new File(tempDirectoryPath + "some-downloaded-file");
                FileUtils.copyURLToFile(mediaURL, localFile);
                

                //Todo, generify by accepting config for path to tool.
                Process mp3InfoProcess = Runtime.getRuntime().exec("/opt/local/bin/mp3info -p \"%S\" " + localFile.getAbsolutePath());
                BufferedReader reader = new BufferedReader(new InputStreamReader(mp3InfoProcess.getInputStream()));

                String resultingValue = "";
                String line;
                while((line = reader.readLine()) != null) {
                    resultingValue += line;
                }

                try {
                    resultingValue = resultingValue.trim();
                    resultingValue = resultingValue.replaceAll("\"", "");


                    Integer durationSeconds = Integer.parseInt(resultingValue);


                    //stuff the value into the metadata field.
                    Duration duration = new Duration(0, 0, durationSeconds);
                    item.addMetadata("dc", "format", "extent", null, "Audio Duration: " + duration.toString());
                    
                    try {
                        item.update();
                        curator.setResult(taskId, "Set Audio Duration to " + duration.toString());
                        return Curator.CURATE_SUCCESS;

                    } catch (Exception e) {
                        curator.setResult(taskId, "Unable to save results");
                        return Curator.CURATE_ERROR;
                    }

                } catch (NumberFormatException e) {
                    curator.setResult(taskId, "Error in processing this media's value. Got:"+resultingValue);
                    return Curator.CURATE_ERROR;
                }



                //fix the output results, to actually display right.

            } else {
                curator.setResult(taskId, "No media present");
                return Curator.CURATE_SKIP;
            }
        } else {
            curator.setResult(taskId, "Not an Item");
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
