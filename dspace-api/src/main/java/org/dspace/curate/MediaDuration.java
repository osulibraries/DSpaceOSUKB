package org.dspace.curate;

import com.sun.syndication.feed.module.itunes.types.Duration;
import org.apache.commons.io.FileUtils;
import org.dspace.content.DCValue;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.ConfigurationManager;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

/**
 * Curation task to extract the audio duration from an MP3 file, and then add that to the metadata for an Item.
 * The specific use case is that the mp3 lives on a remote server and is specified in dc.source.uri
 * Author: Peter Dietz dietz.72@osu.edu
 */
@Distributive
public class MediaDuration extends AbstractCurationTask {
    
    private static String defaultExternalMedia = "dc.source.uri";
    private static String externalSourceField;
    private static String tempDirectoryPath;
    private static String mp3infoPath;
    
    private List<String> results;
    
    public void init(Curator curator, String taskId) throws IOException
    {
        super.init(curator, taskId);
        externalSourceField = getDefaultedConfiguration("webui.feed.podcast.sourceuri", defaultExternalMedia);
        tempDirectoryPath = ConfigurationManager.getProperty("dspace.dir") + "/temp/";
        mp3infoPath = ConfigurationManager.getProperty("mp3info.path");
    }

    @Override
    public int perform(DSpaceObject dso) throws IOException {
        results = new ArrayList<String>();
        
        distribute(dso);
        formatResults();
        return Curator.CURATE_SUCCESS;
    }

    @Override
    public void performItem(Item item) throws IOException {
        DCValue[] externalMedia = item.getMetadata(externalSourceField);
        //http://somepath.to/media.mp3
        
        if(externalMedia != null && externalMedia.length > 0) {

            //skip doing this step if metadata-field is already filled.
            DCValue[] formatExtentMetadata = item.getMetadata("dc.format.extent");
            if(formatExtentMetadata != null && formatExtentMetadata.length > 0) {
                addResult(item, "skip", "Value for dc.format.extent already present.");
                return;
            }

            URL mediaURL = new URL(externalMedia[0].value);

            File localFile = new File(tempDirectoryPath + "some-downloaded-file");
            FileUtils.copyURLToFile(mediaURL, localFile);

            Process mp3InfoProcess = Runtime.getRuntime().exec(mp3infoPath + " -p \"%S\" " + localFile.getAbsolutePath());
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
                    addResult(item, "success", "Set Audio Duration to " + duration.toString());
                    return;

                } catch (Exception e) {
                    addResult(item, "error", "Unable to save results");
                    return;
                }

            } catch (NumberFormatException e) {
                addResult(item, "error", "Error in processing this media's value. Got:"+resultingValue);
                return;
            }

        } else {
            addResult(item, "skip", "No media present");
            return;
        }
    }
    
    private void addResult(Item item, String status, String message) {
        results.add(item.getHandle() + " (" + status + ") " + message);
    }

    // utility to get config property with default value when not set.
    private static String getDefaultedConfiguration(String key, String dfl)
    {
        String result = ConfigurationManager.getProperty(key);
        return (result == null) ? dfl : result;
    }
    
    private void formatResults() {
        StringBuilder outputResult = new StringBuilder();
        for(String result : results) {
            outputResult.append(result).append("\n");
        }
        setResult(outputResult.toString());
    }
            
}
