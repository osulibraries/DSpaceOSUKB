/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.curate.demo;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

/**
 * GoogleTranslator
 * ----------------
 * GoogleTranslator translates metadata fields using Google Translate API v2
 *
 * Requirements: A valid Google API key (the new v2-style "Simple API Access" keys)
 *               More information: https://code.google.com/apis/console
 *
 *               This key, and other custom configuration, goes in [dspace]/modules/translator.cfg
 *
 * @author Kim Shepherd
 */

public class GoogleTranslator extends AbstractTranslator
{

    private static final String PLUGIN_PREFIX = "translator";

    private static final String baseUrl = "https://www.googleapis.com/language/translate/v2";
    private static String apiKey = "";

    private static Logger log = Logger.getLogger(GoogleTranslator.class);

    private List<String> results = null;

    @Override
    protected void initApi() {
        apiKey =  ConfigurationManager.getProperty(PLUGIN_PREFIX, "translate.api.key.google");
    }

    @Override
    protected String translateText(String from, String to, String text) throws IOException {

        log.debug("Performing API call to translate from " + from + " to " + to);

        text = URLEncoder.encode(text, "UTF-8");

        String translatedText = null;

        String url = baseUrl + "?key=" + apiKey;
        url += "&source=" + from + "&target=" + to + "&q=" + text;

        HttpClient client = new HttpClient();
        HttpMethod hm = new GetMethod(url);
        int code = client.executeMethod(hm);
        log.debug("Response code from API call is " + code);

        if(code == 200) {
            String response = hm.getResponseBodyAsString();
            try
            {
                JSONArray ja = JSONArray.fromObject(JSONObject.fromObject(JSONObject.fromObject(response).get("data")).get("translations"));

                if(ja.size() > 0)
                {
                    JSONObject jt = ja.getJSONObject(0);
                    translatedText = jt.get("translatedText").toString();
                    translatedText = StringEscapeUtils.unescapeHtml(translatedText);
                }

            }
            catch(Exception e)
            {
                log.info("Error reading Google API response: " + e.getLocalizedMessage());
            }


        }

        return translatedText;
    }

}

