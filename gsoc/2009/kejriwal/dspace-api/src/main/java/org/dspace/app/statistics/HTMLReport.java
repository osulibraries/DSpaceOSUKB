/*
 * HTMLReport.java
 *
 * Version: $Revision$
 *
 * Date: $Date$
 *
 * Copyright (c) 2002-2009, The DSpace Foundation.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the DSpace Foundation nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

package org.dspace.app.statistics;

import org.dspace.app.statistics.Report;
import org.dspace.app.statistics.Stat;
import org.dspace.app.statistics.Statistics;
import org.dspace.app.statistics.ReportTools;
import org.dspace.core.ConfigurationManager;

import java.text.DateFormat;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.*;

/**
 * This class provides HTML reports for the ReportGenerator class
 *
 * @author  Richard Jones
 */
public class HTMLReport implements Report
{
    // FIXME: all of these methods should do some content escaping before
    // outputting anything
    
    /** a list of the statistic blocks being managed by this class */
    private List blocks = new ArrayList();
    
    /** the title for the page */
    private String pageTitle = null;
    
    /** the main title for the page */
    private String mainTitle = null;
    
    /** start date for report */
    private Date start = null;
    
    /** end date for report */
    private Date end = null;

    /** the output file to which to write aggregation data */
   private static String output = ConfigurationManager.getProperty("dspace.dir") +
                            File.separator + "log" + File.separator + "report";
    
    /**
     * constructor for HTML reporting
     */
    public void HTMLReport()
    {
        // empty constructor
    }

    public void setOutput(String newOutput)
    {
        if (newOutput != null)
        {
            output = newOutput;
        }
    }
    
    /**
     * return a string containing the report as generated by this class
     *
     * @return      the HTML report
     */
    public String render()
    {
        StringBuffer frag = new StringBuffer();
        
        // get the page headings
        frag.append(header(pageTitle));
        frag.append(mainTitle());
        frag.append(dateRange());
        
        // output the report blocks
        // FIXME: perhaps the order of report blocks should be configurable
        Iterator statSets = blocks.iterator();
        while (statSets.hasNext())
        {
            frag.append(navigation());
            
            Statistics stats = (Statistics) statSets.next();
            frag.append(sectionHeader(stats.getSectionHeader()));
            frag.append(topLink());
            frag.append(blockExplanation(stats.getExplanation()));
            frag.append(floorInfo(stats.getFloor()));
            frag.append(statBlock(stats));
        }
        
        // output the footer and return
        frag.append(footer());

        // NB: HTMLReport now takes responsibility to write the output file,
        // so that the Report/ReportGenerator can have more general usage
        // finally write the string into the output file
        try
        {
        	FileOutputStream fos = new FileOutputStream(output);
            OutputStreamWriter osr = new OutputStreamWriter(fos, "UTF-8");
            PrintWriter out = new PrintWriter(osr);
            out.write(frag.toString());
            out.close();
        }
        catch (IOException e)
        {
            System.out.println("Unable to write to output file " + output);
            System.exit(0);
        }
        
        return frag.toString();
    }
    
    
    /**
     * provide a link back to the top of the page
     *
     * @return      a string containing the link text HTML formatted
     */
    public String topLink()
    {
        String frag = "<div class=\"reportNavigation\"><a href=\"#top\">Top</a></div>";
        return frag;
    }
    
    
    /**
     * build the internal navigation for the report
     *
     * @return      an HTML string providing internal page navigation
     */
    public String navigation()
    {
        StringBuffer frag = new StringBuffer();
        
        frag.append("<div class=\"reportNavigation\">");
        frag.append("<a href=\"#general_overview\">General Overview</a>");
        frag.append("&nbsp;|&nbsp;");
        frag.append("<a href=\"#archive_information\">Archive Information</a>");
        frag.append("&nbsp;|&nbsp;");
        frag.append("<a href=\"#items_viewed\">Items Viewed</a>");
        frag.append("&nbsp;|&nbsp;");
        frag.append("<a href=\"#all_actions_performed\">All Actions Performed</a>");
        frag.append("&nbsp;|&nbsp;");
        frag.append("<a href=\"#user_logins\">User Logins</a>");
        frag.append("&nbsp;|&nbsp;");
        frag.append("<a href=\"#words_searched\">Words Searched</a>");
        frag.append("&nbsp;|&nbsp;");
        frag.append("<a href=\"#averaging_information\">Averaging Information</a>");
        frag.append("&nbsp;|&nbsp;");
        frag.append("<a href=\"#log_level_information\">Log Level Information</a>");
        frag.append("&nbsp;|&nbsp;");
        frag.append("<a href=\"#processing_information\">Processing Information</a>");
        frag.append("</div>");
        
        return frag.toString();
    }
    
    /**
     * add a statistics block to the report to the class register
     *
     * @param   stat    the statistics object to be added to the report
     */
    public void addBlock(Statistics stat)
    {
        blocks.add(stat);
        return;
    }
    
    
    /**
     * set the starting date for the report
     *
     * @param   start   the start date for the report
     */
    public void setStartDate(Date start)
    {
        this.start = start;
    }
    
    
    /**
     * set the end date for the report
     *
     * @param   end     the end date for the report
     */
    public void setEndDate(Date end)
    {
        this.end = end;
    }
    
    
    /**
     * output the date range in the relevant format.  This requires that the
     * date ranges have been set using setStartDate() and setEndDate()
     *
     * @return      a string containing date range information
     */
    public String dateRange()
    {
        StringBuffer frag = new StringBuffer();
        DateFormat df = DateFormat.getDateInstance();
        
        frag.append("<div class=\"reportDate\">");
        if (start != null)
        {
            frag.append(df.format(start));
        }
        else
        {
            frag.append("from start of records ");
        }
        
        frag.append(" to ");
        
        if (end != null)
        {
            frag.append(df.format(end));
        }
        else
        {
            frag.append(" end of records");
        }
        
        frag.append("</div>\n\n");
        
        return frag.toString();
    }
    
    
    /**
     * output the title in the relevant format.  This requires that the title
     * has been set with setMainTitle()
     *
     * @return      a string containing the title of the report
     */
    public String mainTitle()
    {
        String frag = "<div class=\"reportTitle\"><a name=\"top\">" + mainTitle + "</a></div>\n\n";
        return frag;
    }
    
    
    /**
     * set the main title for the report
     *
     * @param   name    the name of the service
     * @param   serverName  the name of the server
     */
    public void setMainTitle(String name, String serverName)
    {
        mainTitle = "Statistics for " + name + " on " + serverName;
        if (pageTitle == null)
        {
            pageTitle = mainTitle;
        }
        return;
    }
    
    
    /**
     * output any top headers that this page needs
     *
     * @return      a string containing the header for the report
     */
    public String header()
    {
        return header("");
    }
    
    /**
     * output any top headers that this page needs, and include a title
     * argument (Title support currently not implemented)
     *
     * @param   title   the title of the item being headered
     */
    public String header(String title)
    {
        // FIXME: this need to be figured out to integrate nicely into the 
        // whole JSTL thing, but for the moment it's just going to deliver
        // some styles
        StringBuffer frag = new StringBuffer();
        
        frag.append("<style type=\"text/css\">\n");
        frag.append("body { font-family: Arial, Helvetica, sans-serif }");
        frag.append(".reportTitle { width: 100%; clear: both; text-align: center; font-weight: bold; font-size: 200%; margin: 20px; }\n");
        frag.append(".reportSection { width: 100%; clear: both; font-weight: bold; font-size: 160%; margin: 10px; text-align: center; margin-top: 30px; }\n");
        frag.append(".reportBlock { border: 1px solid #000000; margin: 10px; }\n");
        frag.append(".reportOddRow { background: #dddddd; }\n");
        frag.append(".reportEvenRow { background: #bbbbbb; }\n");
        frag.append(".reportExplanation { font-style: italic; text-align: center; }\n");
        frag.append(".reportDate { font-style: italic; text-align: center; font-size: 120% }\n");
        frag.append(".reportFloor { text-align: center; }\n");
        frag.append(".rightAlign { text-align: right; }\n");
        frag.append(".reportNavigation { text-align: center; }\n");
        frag.append("</style>\n");
        
        return frag.toString();
    }
   
   
    /**
     * output the section header in HTML format
     *
     * @param   title   the title of the section
     *
     * @return          a string containing the section title HTML formatted
     */
    public String sectionHeader(String title)
    {
        // prepare the title to be an <a name="#title"> style link
        // FIXME: this should be made more generic and used in a number of locations
        String aName = title.toLowerCase();
        Pattern space = Pattern.compile(" ");
        Matcher matchSpace = space.matcher(aName);
        aName = matchSpace.replaceAll("_");

        String frag = "<div class=\"reportSection\"><a name=\"" + aName + "\">" + title + "</a></div>\n\n";
        return frag;
    }
    
    
    /**
     * output the report block based on the passed mapping, where the mapping
     * sould be "name of report element" => "value", where both sides of the
     * mapping should be Strings.  This class also assumes that the reference
     * is a linkable URL to the resource
     *
     * @param   content     the statistic object array to be displayed
     *
     * @return              a string containing the statistics block HTML formatted
     */
    public String statBlock(Statistics content)
    {
        StringBuffer frag = new StringBuffer();
        Stat[] stats = content.getStats();
        
        // start the table
        frag.append("<table align=\"center\" class=\"reportBlock\" cellpadding=\"5\">\n");
        
        // prepare the table headers
        if (content.getStatName() != null || content.getResultName() != null)
        {
            frag.append("\t<tr>\n");
            frag.append("\t\t<th>\n");
            if (content.getStatName() != null)
            {
                frag.append("\t\t\t" + content.getStatName() + "\n");
            }
            else
            {
                frag.append("\t\t\t&nbsp;\n");
            }
            frag.append("\t\t</th>\n");
            frag.append("\t\t<th>\n");
            if (content.getResultName() != null)
            {
                frag.append("\t\t\t" + content.getResultName() + "\n");
            }
            else
            {
                frag.append("\t\t\t&nbsp;\n");
            }
            frag.append("\t\t</th>\n");
            frag.append("\t</tr>\n");
        }
        
        // output the statistics in the table
        for (int i = 0; i < stats.length; i++)
        {
            String style = null;
 
            if ((i % 2) == 1)
            {
                style = "reportOddRow";
            }
            else
            {
                style = "reportEvenRow";
            }
            
            frag.append("\t<tr class=\"" + style + "\">\n\t\t<td>\n");
            frag.append("\t\t\t");
            if (stats[i].getReference() != null)
            {
                frag.append("<a href=\"" + stats[i].getReference() + "\" ");
                frag.append("target=\"_blank\">");
            }
            frag.append(this.clean(stats[i].getKey()));
            if (stats[i].getReference() != null)
            {
                frag.append("</a>");
            }
            frag.append("\n");
            frag.append("\t\t</td>\n\t\t<td class=\"rightAlign\">\n");
            frag.append("\t\t\t" + ReportTools.numberFormat(stats[i].getValue()));
            if (stats[i].getUnits() != null)
            {
                frag.append(" " + stats[i].getUnits());
            }
            frag.append("\n");
            frag.append("\t\t</td>\n\t</tr>\n");
        }
        
        frag.append("</table>\n");
        
        return frag.toString();
    }
    
    
    /**
     * output the floor information in HTML format
     *
     * @param   floor   the floor number for the section being displayed
     *
     * @return          a string containing floor information HTML formatted
     */
    public String floorInfo(int floor)
    {
        if (floor > 0)
        {
            StringBuffer frag = new StringBuffer();
            frag.append("<div class=\"reportFloor\">");
            frag.append("(more than " + ReportTools.numberFormat(floor) + " times)");
            frag.append("</div>\n");
            return frag.toString();
        }
        else
        {
            return "";
        }
    }
    
    /**
     * output the explanation of the report block in HTML format
     *
     * @param   explanation     some text explaining the coming report block
     *
     * @return      a string containing an explanaton HTML formatted
     */
    public String blockExplanation(String explanation)
    {
        if (explanation != null)
        {
            StringBuffer frag = new StringBuffer();
            frag.append("<div class=\"reportExplanation\">");
            frag.append(explanation);
            frag.append("</div>\n\n");
            return frag.toString();
        }
        else
        {
            return "";
        }
    }
    
    /**
     * output the final footers for this file
     *
     * @return      a string containing the report footer
     */
    public String footer()
    {
        return "";
    }

    /**
     * Clean Stirngs for display in HTML
     *
     * @param s The String to clean
     * @return The cleaned String
     */
    private String clean(String s)
    {
        // Clean up the statistics keys
        s = s.replace("<", "&lt;");
        s = s.replaceAll(">", "&gt;");
        return s;
    }
    
}
