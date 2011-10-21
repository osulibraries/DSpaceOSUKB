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

import org.apache.pdfbox.pdmodel.common.PDRectangle;

import org.apache.pdfbox.pdmodel.edit.PDPageContentStream;

import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;

import org.apache.pdfbox.util.PDFMergerUtility;

import org.dspace.content.Bitstream;
import org.dspace.content.BitstreamFormat;
import org.dspace.content.Bundle;
import org.dspace.content.Collection;
import org.dspace.content.DCValue;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;

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
                            + bitstream.getName() + " is citable");
                    try {
                        /*
                         * Process for adding cover page is as follows:
                         *  1. Load source file into PDDocument and create
                         *     another PDDocuemnt to put our cover page into.
                         *  2. Create cover page and add content to it.
                         *  3. Concatenate the document with the cover page and
                         *     the original source document.
                         */
                        PDDocument originalDoc = PDDocument.load(bitstream.retrieve());
                        PDDocument citedDoc = new PDDocument();
                        if (originalDoc == null) {
                            // Could not create PDF because of a bad format.
                            this.resBuilder
                                    .append(", but it is an invalid format.\n");
                            this.status = Curator.CURATE_FAIL;
                        } else {
                            // Create a Citation page and add it to front of our
                            // original document
                            try {
                                //Determine the size of the first page so the
                                //citation page can be the same.
                                List<PDPage> pages = (List<PDPage>) originalDoc.getDocumentCatalog().getAllPages();
                                PDRectangle firstPageRectangle = pages.get(0).getTrimBox();

                                //Create the cover page using the size we found
                                //above and add it to our cited document.
                                PDPage coverPage = new PDPage(firstPageRectangle);
                                citedDoc.addPage(coverPage);

                                //Create content stream to add content to the
                                //citation page.
                                PDPageContentStream contentStream = new PDPageContentStream(
                                        citedDoc, coverPage);
                                CitationPage.generateCoverPage(contentStream, new CitationMeta(item));

                                //Use PDFMergerUtility to concatenate cover page
                                //document and source document.
                                PDFMergerUtility concatenator = new PDFMergerUtility();
                                concatenator.appendDocument(citedDoc, originalDoc);

                                //Save our file to a temporary file/output stream
                                File temp = File.createTempFile(bitstream.getName(), ".citation.pdf");
                                OutputStream sto = new FileOutputStream(temp);
                                citedDoc.save(sto);

                                //Close it all up
                                citedDoc.close();
                                originalDoc.close();
                                sto.close();

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
                                InputStream inp = new FileInputStream(temp);
                                Bitstream citedBitstream = citationBundle.createBitstream(inp);
                                inp.close(); //Close up the temporary InputStream

                                //Setup a good name for our bitstream and make
                                //it the same format as the source document.
                                citedBitstream.setName("cited-" + bitstream.getName());
                                citedBitstream.setFormat(bitstream.getFormat());


                                //Run update to propagate changes to the
                                //database.
                                item.update();
                                this.status = Curator.CURATE_SUCCESS;
                            } catch (Exception e) {
                                //Could be many things
                                log.error("Something went wrong while generating a PDF: " +e.getMessage());
                                this.resBuilder.append(", but there was an error generating the PDF.\n");
                                this.status = Curator.CURATE_ERROR;
                            }
                        }
                    } catch (Exception e) {
                        // Could not convert doc to a PDF because of an
                        // IOException
                        log.error("Could not convert document to PDF: " + e.getMessage());
                        this.resBuilder
                                .append(", but it could not be converted to a PDF.\n");
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
     * @param cStream
     *            The content stream to write the cover page to.
     * @param cMeta
     *            METADATA retrieved from the parent collection.
     * @throws IOException
     */
    private static void generateCoverPage(PDPageContentStream cStream,
            CitationMeta cMeta) throws IOException {
        // TODO: Fill in Cover Page creation.
        PDFont font = PDType1Font.TIMES_ROMAN;
        cStream.setFont(font, 14);
        CitationPage.generateCoverPageHeader(cStream);
        cStream.beginText();
        cStream.moveTextPositionByAmount(50, 100);
        cStream.drawString(cMeta.getName());
        cStream.drawString(cMeta.toString());
        cStream.endText();
        cStream.close();
    }

    /**
     * Helper function for {@link CitationPage.generateCoverPage()}. Generates
     * content for the header.
     *
     * @param cStream
     *            The content stream to write the cover page to.
     */
    private static void generateCoverPageHeader(PDPageContentStream cStream)
            throws IOException {
        cStream.beginText();
        cStream.moveTextPositionByAmount(50, 40);
        cStream.drawString("CitationPage\nEverybody PARTY!\n\n");
        cStream.endText();
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
        public CitationMeta(Item item) throws SQLException {
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
         * Nicely print out what CitationMeta is.
         *
         * @return A string in with the format:
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
