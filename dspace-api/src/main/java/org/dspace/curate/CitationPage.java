/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.curate;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;

import java.sql.SQLException;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

import org.dspace.content.Bitstream;
import org.dspace.content.BitstreamFormat;
import org.dspace.content.Bundle;
import org.dspace.content.Collection;
import org.dspace.content.DCValue;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Paragraph;

import com.itextpdf.text.pdf.AcroFields;
import com.itextpdf.text.pdf.PdfConcatenate;
import com.itextpdf.text.pdf.PdfPageLabels;
import com.itextpdf.text.pdf.PdfReader;
import com.itextpdf.text.pdf.PdfWriter;

import com.itextpdf.text.Rectangle;

/**
 * CitationPage
 *
 * This task is used to generate a cover page with citation information for text
 * documents and then to add that cover page to a PDF version of the document
 * replacing the originally uploaded document form the user's perspective.
 *
 * @author Ryan McGowan
 */

@Distributive
@Mutative
public class CitationPage extends AbstractCurationTask {

    private int status = Curator.CURATE_UNSET;
    private String result = null;
    /**
     * A StringBuilder to handle result string building process.
     */
    private StringBuilder resBuilder;
    /**
     * A set of MIME types that can have a citation page added to them. That is,
     * MIME types in this set can be converted to a PDF which is then prepended
     * with a citation page.
     */
    private static final Set<String> validTypes = new HashSet<String>(2);
    /**
     * Sequence of fields wanted to be used
     */
    private static List<String> desiredMeta;
    /**
     * Class Logger
     */
    private static final Logger log = Logger.getLogger(CitationPage.class);
    /**
     * The name to give the bundle we add the cited pages to.
     */
    private static final String bundleName = "CITATION";

    static {
        // Add valid format MIME types to set. This could be put in the Schema
        // instead.
        CitationPage.validTypes.add("application/pdf");
        CitationPage.validTypes.add("application/x-pdf");

        // List METADATA fields wanted to create the cover page.
        CitationPage.desiredMeta = new LinkedList<String>();
        CitationPage.desiredMeta.add("title");
    }

    /**
     * {@inheritDoc}
     * @see CurationTask#perform(DSpaceObject)
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException {

        // Deal with status and result as well as call distribute.
        this.resBuilder = new StringBuilder();
        this.distribute(dso);
        this.result = this.resBuilder.toString();
        this.setResult(this.result);
        this.report(this.result);

        return this.status;
    }

    /**
     * {@inheritDoc}
     * @see AbstractCurationTask#performItem(Item)
     */
    @Override
    protected void performItem(Item item) throws SQLException {
        // Should return single element array with the ORIGINAL bundle
        Bundle[] bundles = item.getBundles("ORIGINAL");
        for (Bundle bundle : bundles) {
            Bitstream[] bitstreams = bundle.getBitstreams();
            // Loop through each file and generate a cover page for documents
            // that can be converted to a PDF.
            for (Bitstream bitstream : bitstreams) {
                BitstreamFormat format = bitstream.getFormat();

                //If bitstream is a document which can be converted to a PDF
                if (CitationPage.validTypes.contains(format.getMIMEType())) {
                    this.resBuilder.append(item.getHandle() + " - "
                            + bitstream.getName() + " is citable.");
                    try {
                        /*
                         * Process for adding cover page is as follows:
                         *  1. Load source file into PdfReader and create a
                         *     Document to put our cover page into.
                         *  2. Create cover page and add content to it.
                         *  3. Concatenate the coverpage and the source
                         *     document.
                         */
                        PdfReader source = new PdfReader(bitstream.retrieve());
                        //TODO: Fix page labels
                        String[] labels = PdfPageLabels.getPageLabels(source);
                        
                        //Determine the size of the first page so the
                        //citation page can be the same.
                        Rectangle pdfSize = source.getCropBox(1);
                        Document citedDoc = new Document(pdfSize);
                        File coverTemp = File.createTempFile(bitstream.getName(), ".cover.pdf");
                        //Need a writer instance to make changed to the
                        //document.
                        PdfWriter.getInstance(citedDoc, new FileOutputStream(coverTemp));

                        //Call helper function to add content to the coverpage.
                        CitationPage.generateCoverPage(citedDoc, new CitationMeta(item, source.getAcroFields()));

                        //Create reader from finished cover page.
                        PdfReader citedReader = new PdfReader(new FileInputStream(coverTemp));

                        //Concatente the finished cover page with the source
                        //document.
                        File citedTemp = File.createTempFile(bitstream.getName(), ".cited.pdf");
                        PdfConcatenate concat = new PdfConcatenate(new FileOutputStream(citedTemp));
                        concat.open();
                        concat.addPages(citedReader);
                        concat.addPages(source);

                        //Put all of our labels in from the orignal document.
                        PdfPageLabels citedPageLabels = new PdfPageLabels();
                        citedPageLabels.addPageLabel(1, PdfPageLabels.EMPTY, "Citation Page");
                        log.debug("Printing arbitrary page labels.");
                        for (int i = 0; i < labels.length; i++) {
                            log.debug("Label for page: " + (i + 2) + " -> " + labels[i]);
                            citedPageLabels.addPageLabel(i + 2, PdfPageLabels.EMPTY, labels[i]);
                        }
                        concat.getWriter().setPageLabels(citedPageLabels);

                        //Close it up
                        concat.close();

                        //If the CITATION bundle already exists, remove
                        //it and start again.
                        Bundle[] citationBundles = item.getBundles(CitationPage.bundleName);
                        if (citationBundles.length > 0) {
                            //Remove all Bundles with the name CITATION
                            for (Bundle b : citationBundles) {
                                item.removeBundle(b);
                            }
                        }
                        Bundle citationBundle = item.createBundle(CitationPage.bundleName);

                        //Create an input stream form the temporary file
                        //that is the cited document and create a
                        //bitstream from it.
                        InputStream inp = new FileInputStream(citedTemp);
                        Bitstream citedBitstream = citationBundle.createBitstream(inp);
                        inp.close(); //Close up the temporary InputStream

                        //Setup a good name for our bitstream and make
                        //it the same format as the source document.
                        citedBitstream.setName("cited-" + bitstream.getName());
                        citedBitstream.setFormat(bitstream.getFormat());

                        this.resBuilder.append(" Added "
                                + citedBitstream.getName()
                                + " to the " + CitationPage.bundleName + " bundle.\n");

                        //Run update to propagate changes to the
                        //database.
                        item.update();
                        this.status = Curator.CURATE_SUCCESS;
                    } catch (Exception e) {
                        //Could be many things
                        e.printStackTrace();
                        StackTraceElement[] stackTrace = e.getStackTrace();
                        StringBuilder stack = new StringBuilder();
                        int numLines = Math.min(stackTrace.length, 12);
                        for (int i = 0; i < numLines; i++) {
                            stack.append("\t" + stackTrace[i].toString() + "\n");
                        }
                        log.error(e.toString() + " -> \n" + stack.toString());
                        this.resBuilder.append(", but there was an error generating the PDF.\n");
                        this.status = Curator.CURATE_ERROR;
                    }
                } else {
                    //bitstream is not a document
                    this.resBuilder.append(item.getHandle() + " - "
                            + bitstream.getName() + " is not citable.\n");
                    this.status = Curator.CURATE_SUCCESS;
                }
            }
        }
    }

    /**
     * Takes a DSpace {@link Bitstream} and uses its associated METADATA to
     * create a cover page.
     *
     * @param cDoc The cover page document to add cited information to.
     * @param cMeta
     *            METADATA retrieved from the parent collection.
     * @throws IOException
     * @throws DocumentException 
     */
    private static void generateCoverPage(Document cDoc, CitationMeta cMeta)
            throws IOException, DocumentException {
        // TODO: Fill in Cover Page creation.
        cDoc.open();

        //Iterate through METADATA and display each entry
        for (Map.Entry<String, String> entry : cMeta.getMetaData().entrySet()) {
            cDoc.add(new Paragraph(entry.getKey() + ": " + entry.getValue() + "\n"));
        }

        cDoc.close();
   }

    /**
     *
     */
    private class CitationMeta {
        private Bitstream pLogo;
        private String pName;
        private Collection parent;
        private Map<String, String> metaData;
        private Map<String, String> parentMetaData;
        private Item myItem;

        /**
         * Constructs CitationMeta object from an Item. It uses item specific
         * METADATA as well as METADATA from the owning collection.
         *
         * @param item An Item to get METADATA from.
         * @throws SQLException
         */
        public CitationMeta(Item item, AcroFields fields) throws SQLException {
            this.myItem = item;
            this.metaData = new HashMap<String, String>();
            //Get all METADATA from our this.myItem
            DCValue[] dcvs = this.myItem.getMetadata(Item.ANY, Item.ANY, Item.ANY, Item.ANY);
            //Put METADATA in a Map for easy access.
            for (DCValue dsv : dcvs) {
                //TODO: Make the key correct
                String key = dsv.schema + "." + dsv.element + "." + dsv.qualifier + "." + dsv.language;
                this.metaData.put(key, dsv.value);
            }

            //Get METADATA from the owning Collection
            this.parent = this.myItem.getOwningCollection();
            this.pLogo = this.parent.getLogo();
            this.pName = this.parent.getName();

            //Loop through desiredMeta gathering what we can from the
            //Collection specific METADATA.
            for (String desired : CitationPage.desiredMeta) {
                this.addCollectionMeta(desired);
            }
        }

        /**
         * Returns the name of the collection the item is in.
         *
         * @return The name of the collection.
         */
        public String getName() {
            return this.pName;
        }

        public Item getItem() {
            return this.myItem;
        }

        /**
         * Returns the logo of the parent collection.
         *
         * @return The logo set on the parent collection.
         */
        public Bitstream getLogo() {
            return this.pLogo;
        }

        /**
         * Returns a map of the METADATA for the item associated with this
         * instance of CitationMeta.
         *
         * @return a Map of the METADATA for the associated item.
         */
        public Map<String, String> getMetaData() {
            return this.metaData;
        }

        /**
         * Return the meta field associated with the given key. Requires metaKey
         * to be specified.
         *
         * @param metaKey
         *            The referencing string.
         * @return The meta field string be referred to.
         */
        public String getMetaValue(String metaKey) {
            return this.metaData.get(metaKey);
        }

        /**
         * True if the given key is in METADATA set.
         *
         * @param metaKey
         *            The key being searched for.
         * @return Given metaKey is in this.metaData.
         */
        public boolean containsMeta(String metaKey) {
            return this.metaData.containsKey(metaKey);
        }

        /**
         * Add META field referenced by metaKey to internal storage.
         *
         * @param metaKey
         *            A key describing the meta field being added.
         * @return Found related meta field and added it. Returns false if it
         *         was not found in collection META.
         */
        private boolean addCollectionMeta(String metaKey) {
            try {
                String metaValue = this.parent.getMetadata(metaKey);
                parentMetaData.put(metaKey, metaValue);
                return true;
            } catch (IllegalArgumentException ie) {
                return false;
            }
        }

        /**
         * {@inheritDoc}
         * @see Object#toString()
         * @return A string with the format:
         *  CitationMeta {
         *      CONTENT
         *  }
         *  Where CONTENT is the METADATA derived by this class.
         */
        @Override
        public String toString() {
            StringBuilder ret = new StringBuilder(CitationMeta.class.getName());
            ret.append(" {<br />\n\t");
            ret.append(this.metaData);
            ret.append("\n\t");
            ret.append(this.pName);
            ret.append("\n\t");
            ret.append(this.parentMetaData);
            ret.append("\n}\n");
            return ret.toString();
        }
    }
}
