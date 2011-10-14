/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.curate;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.pdfbox.exceptions.COSVisitorException;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.edit.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
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
     * A set of MIME types that can have a citation page added to them.
     */
    private static Set<String> validTypes;
    /**
     * Sequence of fields wanted to be used
     */
    private static List<String> desiredMeta;

    static {
        // Add valid format MIME types to set. This could be put in the Schema
        // instead.
        CitationPage.validTypes = new HashSet<String>(2);
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

    @Override
    protected void performItem(Item item) throws SQLException {
        // Should return single element array with a the ORIGINAL bundle
        Bundle[] bundles = item.getBundles("ORIGINAL");
 item.getMetadata("dc", "date", "accessensioned", "");
/* DCValue[] dcv =item.getMetadata(Item.ANY, Item.ANY, Item.ANY, Item.ANY);
 dcv[0].value;
 Collection col = Collection.find(context, 1);
 col.getMetadata("")

dcv[0].
item.getMetadata("dc.date.accessioned");*/


        for (Bundle bundle : bundles) {
            Bitstream[] bitstreams = bundle.getBitstreams();
            // Loop through each file and generate a cover page for documents we
            // can turn into PDFs.
            for (Bitstream bitstream : bitstreams) {
                BitstreamFormat format = bitstream.getFormat();
                if (CitationPage.validTypes.contains(format.getMIMEType())) {
                    this.resBuilder.append(item.getHandle() + " - "
                            + bitstream.getName() + " is citable");
                    try {
                        PDDocument doc = CitationPage.convertToPDF(bitstream);
                        if (doc == null) {
                            // Could not create PDF because of a bad format.
                            this.resBuilder
                                    .append(", but it is an invalid format.\n");
                            this.status = Curator.CURATE_FAIL;
                        } else {
                            // Create a Citation page and add it to front of our
                            // document
                            try {
                                // Construct CitationMeta object if possible
                                PDPage coverPage = new PDPage();
                                doc.addPage(coverPage);
                                
                                PDPageContentStream contentStream = new PDPageContentStream(
                                        doc, coverPage);
                                //TODO: Find a place to save the new PDF
                                this.generateCoverPage(contentStream,
                                        new CitationMeta(item), bitstream);
                                bitstream.
                                doc.save("somefilepath.pdf");
                                this.status = Curator.CURATE_SUCCESS;
                            } catch (SQLException e) {
                                // Couldn't find parent or something went wrong
                                // with database connection
                                e.printStackTrace();
                                this.resBuilder
                                        .append(", but there was an error retrieving the METADATA.");
                                this.status = Curator.CURATE_ERROR;
                            } catch (IOException e) {
                                // Error actually generating the PDF
                                e.printStackTrace();
                                this.resBuilder
                                        .append(", but there was an error generating the cover page.");
                                this.status = Curator.CURATE_ERROR;

                            } catch (COSVisitorException e) {
                                // TODO Auto-generated catch block
                                e.printStackTrace();
                                this.resBuilder
                                        .append(", but there was an error saving the cover page.");
                                this.status = Curator.CURATE_ERROR;
                            }
                        }
                    } catch (IOException ioe) {
                        // Could not convert doc to a PDF because of an IOError
                        this.resBuilder
                                .append(", but it could not be converted to a PDF.\n");
                        this.status = Curator.CURATE_ERROR;
                    }
                } else {
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
     * @param bs
     *            The DSpace Bitstream to use the METADATA of to create a cover
     *            page.
     * @throws IOException
     */
    private void generateCoverPage(PDPageContentStream cStream,
            CitationMeta cMeta, Bitstream bs) throws IOException {
        // TODO: Fill in Cover Page creation.
        PDFont font = PDType1Font.TIMES_ROMAN;
        cStream.beginText();
        cStream.setFont(font, 14);
        cStream.moveTextPositionByAmount(100, 700);
        cStream.drawString(cMeta.getName());
        cStream.endText();
        cStream.close();
    }

    /**
     * Takes a DSpace {@link Bitstream} that is a PDF or can be converted to a
     * PDF and returns the PDDocument of it.
     *
     * @param doc
     *            The DSpace Bitstream to be converted to a PDDocument.
     * @return The converted PDDocument or null on failure.
     * @throws IOException
     */
    private static PDDocument convertToPDF(Bitstream doc) throws IOException {
        PDDocument ret;
        String mimeType = doc.getFormat().getMIMEType();
        if (mimeType.equals("application/pdf")
                || mimeType.equals("application/x-pdf")) {
            // We have a PDF so all we have to do is load it up.
            ret = PDDocument.load(doc.getSource());
        } else {
            ret = null;
        }
        return ret;
    }

    private class CitationMeta {
        private Bitstream logo;
        private String name;
        private Collection parentCollection;
        private Map<String, String> metaData;

        /**
         * Constructs CitationMeta object from DSpaceObject as long as the given
         * DSpaceObject is a collection or an item. Requires dso is not a
         * Community.
         *
         * @param dso
         *            A Collection or Item to get METADATA from.
         * @throws SQLException
         */
        public CitationMeta(DSpaceObject dso) throws SQLException {
            DSpaceObject papa = dso;
            while (!(papa instanceof Collection)) {
                papa = papa.getParentObject();
            }
            this.parentCollection = (Collection) papa;

            this.logo = this.parentCollection.getLogo();
            this.name = this.parentCollection.getName();
            this.metaData = new HashMap<String, String>();

            for (String metaKey : CitationPage.desiredMeta) {
                this.addMeta(metaKey);
            }
        }

        public String getName() {
            return this.name;
        }

        public Bitstream getLogo() {
            return this.logo;
        }

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
        public String getMeta(String metaKey) {
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
        private boolean addMeta(String metaKey) {
            try {
                String metaValue = this.parentCollection.getMetadata(metaKey);
                metaData.put(metaKey, metaValue);
                return true;
            } catch (IllegalArgumentException ie) {
                return false;
            }
        }
    }
}
