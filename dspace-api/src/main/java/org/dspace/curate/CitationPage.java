/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.curate;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;

import java.net.URLConnection;
import java.net.URL;

import java.sql.SQLException;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;

import org.apache.log4j.Logger;

import org.dspace.authorize.AuthorizeException;

import org.dspace.content.Bitstream;
import org.dspace.content.BitstreamFormat;
import org.dspace.content.Bundle;
import org.dspace.content.Collection;
import org.dspace.content.DCValue;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;

import org.dspace.core.ConfigurationManager;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Font;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;

import com.itextpdf.text.pdf.BarcodeQRCode;
import com.itextpdf.text.pdf.PdfConcatenate;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfImportedPage;
import com.itextpdf.text.pdf.PdfPageLabels;
import com.itextpdf.text.pdf.PdfReader;
import com.itextpdf.text.pdf.PdfWriter;

import com.itextpdf.text.Phrase;
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
    private static final Set<String> VALID_TYPES = new HashSet<String>(2);
    /**
     * A set of MIME types that refer to a JPEG, PNG, or GIF
     */
    private static final Set<String> RASTER_MIMES = new HashSet<String>();
    /**
     * A set of MIME types that refer to a SVG
     */
    private static final Set<String> SVG_MIMES = new HashSet<String>();
    /**
     * A set of MIME types that refer to a PDF
     */
    private static final Set<String> PDF_MIMES = new HashSet<String>(2);
    /**
     * Class Logger
     */
    private static Logger log = Logger.getLogger(CitationPage.class);
    /**
     * The name to give the bundle we add the cited pages to.
     */
    private static final String DISPLAY_BUNDLE_NAME = "DISPLAY";
    /**
     * The name of the bundle to move source documents into after they have been
     * cited.
     */
    private static final String PRESERVATION_BUNDLE_NAME = "PRESERVATION";
    /**
     * Tag line for the header of the citation page.
     */
    private static final String HEADER_LINE = ConfigurationManager.getProperty(
            "citationpage", "header_line", "DSpace - Document Management System");
    /**
     * The location of the logo to be used on the citation page.
     */
    private static final String LOGO_RESOURCE = ConfigurationManager.getProperty(
            "citationpage", "logo_resource", "");

    static {
        // Add valid format MIME types to set. This could be put in the Schema
        // instead.
        //Populate RASTER_MIMES
        CitationPage.SVG_MIMES.add("image/jpeg");
        CitationPage.SVG_MIMES.add("image/pjpeg");
        CitationPage.SVG_MIMES.add("image/png");
        CitationPage.SVG_MIMES.add("image/gif");
        //Populate SVG_MIMES
        CitationPage.SVG_MIMES.add("image/svg");
        CitationPage.SVG_MIMES.add("image/svg+xml");
        //Populate PDF_MIMES
        CitationPage.PDF_MIMES.add("application/pdf");
        CitationPage.PDF_MIMES.add("application/x-pdf");

        //Populate VALID_TYPES
        CitationPage.VALID_TYPES.addAll(CitationPage.PDF_MIMES);
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
        //Determine if the DISPLAY bundle exits. If not, create it.
        Bundle[] dBundles = item.getBundles(CitationPage.DISPLAY_BUNDLE_NAME);
        Bundle dBundle = null;
        if (dBundles == null || dBundles.length == 0) {
            try {
                dBundle = item.createBundle(CitationPage.DISPLAY_BUNDLE_NAME);
            } catch (AuthorizeException e) {
                log.error("User not authroized to create bundle on item \""
                        + item.getName() + "\": " + e.getMessage());
            }
        } else {
            dBundle = dBundles[0];
        }

        //Create a map of the bitstreams in the displayBundle. This is used to
        //check if the bundle being cited is already in the display bundle.
        Map<String,Bitstream> displayMap = new HashMap<String,Bitstream>();
        for (Bitstream bs : dBundle.getBitstreams()) {
            displayMap.put(bs.getName(), bs);
        }

        //Determine if the preservation bundle exists and add it if we need to.
        //Also, set up bundles so it contains all ORIGINAL and PRESERVATION
        //bitstreams.
        Bundle[] pBundles = item.getBundles(CitationPage.PRESERVATION_BUNDLE_NAME);
        Bundle pBundle = null;
        Bundle[] bundles = null;
        if (pBundles != null && pBundles.length > 0) {
            pBundle = pBundles[0];
            bundles = (Bundle[]) ArrayUtils.addAll(item.getBundles("ORIGINAL"), pBundles);
        } else {
            try {
                pBundle = item.createBundle(CitationPage.PRESERVATION_BUNDLE_NAME);
            } catch (AuthorizeException e) {
                log.error("User not authroized to create bundle on item \""
                        + item.getName() + "\": " + e.getMessage());
            }
            bundles = item.getBundles("ORIGINAL");
        }

        //Start looping through our bundles. Anything that is citable in these
        //bundles will be cited.
        for (Bundle bundle : bundles) {
            Bitstream[] bitstreams = bundle.getBitstreams();

            // Loop through each file and generate a cover page for documents
            // that are PDFs.
            for (Bitstream bitstream : bitstreams) {
                BitstreamFormat format = bitstream.getFormat();

                //If bitstream is a PDF document then it is citable.
                if (CitationPage.VALID_TYPES.contains(format.getMIMEType())) {
                    this.resBuilder.append(item.getHandle() + " - "
                            + bitstream.getName() + " is citable.");
                    try {
                        //Create the cited document
                        File citedDocument = this.makeCitedDocument(bitstream,
                                new CitationMeta(item));
                        //Add the cited document to the approiate bundle
                        this.addCitedPageToItem(citedDocument, bundle, pBundle,
                                dBundle, displayMap, item, bitstream);
                    } catch (Exception e) {
                        //Could be many things, but nothing that should be
                        //expected.
                        //Print out some detailed information for debugging.
                        e.printStackTrace();
                        StackTraceElement[] stackTrace = e.getStackTrace();
                        StringBuilder stack = new StringBuilder();
                        int numLines = Math.min(stackTrace.length, 12);
                        for (int j = 0; j < numLines; j++) {
                            stack.append("\t" + stackTrace[j].toString() + "\n");
                        }
                        if (stackTrace.length > numLines) {
                            stack.append("\t. . .\n");
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
     * @param writer
     * @param cMeta
     *            METADATA retrieved from the parent collection.
     * @throws IOException
     * @throws DocumentException
     */
    private void generateCoverPage(Document cDoc, PdfWriter writer,
            CitationMeta cMeta) throws DocumentException {
        cDoc.open();
        writer.setCompressionLevel(0);
        cDoc.addHeader(cMeta.getCollection().getName() + ": "
                + cMeta.getItem().getName(), CitationPage.HEADER_LINE);

        //Set up some fonts
        Font beforeAfterFont = FontFactory.getFont(FontFactory.TIMES_BOLD, 12f, new BaseColor(153, 0, 0));
        Font titleFont = FontFactory.getFont(FontFactory.TIMES_ROMAN, 30f, new BaseColor(0, 0, 0));
        Font headerFont = FontFactory.getFont(FontFactory.TIMES_ROMAN, 18f, new BaseColor(9, 9, 9));

        //Construct title and header paragraphs
        Paragraph title = new Paragraph(cMeta.getItem().getName(), titleFont);

        Phrase beforeCollection = new Phrase(1f, "from the ", beforeAfterFont);
        Phrase collection = new Phrase(1f, cMeta.getCollection().getName(), headerFont);
        Phrase afterCollection = new Phrase(1f, " collection", beforeAfterFont);

        Paragraph fromThe = new Paragraph(beforeCollection);
        fromThe.add(collection);
        fromThe.add(afterCollection);

        title.setLeading(0f, 1f);
        fromThe.setLeading(1f, 1.5f);
        fromThe.setSpacingAfter(10f);
        cDoc.add(title);
        cDoc.add(fromThe);

        //Add OSU logo to citation page.
        if (CitationPage.LOGO_RESOURCE.length() > 0) {
            if (!this.addLogoToDocumnet(cDoc, writer, CitationPage.LOGO_RESOURCE)) {
                log.debug("Unable to add logo from " + CitationPage.LOGO_RESOURCE);
            }
        }

        //Iterate through METADATA and display each entry
        Font metaKeyFont = FontFactory.getFont(FontFactory.COURIER_BOLD, 11f, new BaseColor(24, 24, 24));
        String handleURI = null;
        for (Map.Entry<String, String> entry : cMeta.getMetaData().entrySet()) {
            //Construct a nicely fomatted string.
            Rectangle pageSize = cDoc.getPageSize();
            Float remainingWidth = (pageSize.getWidth() - cDoc.rightMargin() - cDoc.leftMargin()) / 10.0f - entry.getKey().length();
            log.debug("Remaining width: " + remainingWidth);
            Paragraph metaItem = new Paragraph();
            metaItem.add(new Phrase(1f, entry.getKey() + ": ", metaKeyFont));
            if (entry.getValue().length() < remainingWidth) {
                metaItem.add(new Phrase(entry.getValue()));
                cDoc.add(metaItem);
            } else {
                cDoc.add(metaItem);
                Paragraph valPara = new Paragraph(entry.getValue());
                valPara.setLeading(0f, 1.1f);
                valPara.setSpacingAfter(0.5f);
                valPara.setIndentationLeft(36f);
                cDoc.add(valPara);
            }
            if (entry.getKey().toLowerCase().contains("identifier.uri")) {
                handleURI = entry.getValue();
                log.debug("Found handle URI: " + entry.getKey() + " -> " + entry.getValue());
            }
        }

        //If we have a handle, make a QR code to it
        if (handleURI != null) {
            BarcodeQRCode qrCode = new BarcodeQRCode(handleURI, 100, 100, null);
            Image qrImage = qrCode.getImage();
            float x = cDoc.getPageSize().getWidth() - qrImage.getScaledWidth();
            float y = 0;
            qrImage.setAbsolutePosition(x, y);
            cDoc.add(qrImage);
            //Writer a label for the QR Code
            PdfContentByte cb = writer.getDirectContent();
            cb.beginText();
            cb.moveText(x, y + qrImage.getHeight() - 15f);
            cb.setFontAndSize(FontFactory.getFont(FontFactory.HELVETICA).getBaseFont(), 6f);
            cb.showText(handleURI);
            cb.endText();
        }

        cDoc.close();
   }

    /**
     * This wraps the item used in its constructor to make it easier to access
     * METADATA.
     */
    private class CitationMeta {
        private Collection parent;
        private Map<String, String> metaData;
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
                String[] dsvParts = {dsv.schema, dsv.element, dsv.qualifier, dsv.language, dsv.authority};
                StringBuilder keyBuilder = new StringBuilder();
                for (String part : dsvParts) {
                    if (part != null && part != "") {
                        keyBuilder.append(part + '.');
                    }
                }
                //Remove the trailing '.'
                keyBuilder.deleteCharAt(keyBuilder.length() - 1);
                this.metaData.put(keyBuilder.toString(), dsv.value);
            }

            //Get METADATA from the owning Collection
            this.parent = this.myItem.getOwningCollection();
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

        public Item getItem() {
            return this.myItem;
        }

        public Collection getCollection() {
            return this.parent;
        }

        /**
         * {@inheritDoc}
         * @see Object#toString()
         * @return A string with the format:
         *  CitationPage.CitationMeta {
         *      CONTENT
         *  }
         *  Where CONTENT is the METADATA derived by this class.
         */
        @Override
        public String toString() {
            StringBuilder ret = new StringBuilder(CitationMeta.class.getName());
            ret.append(" {<br />\n\t");
            ret.append(this.parent.getName());
            ret.append("\n\t");
            ret.append(this.myItem.getName());
            ret.append("\n\t");
            ret.append(this.metaData);
            ret.append("\n}\n");
            return ret.toString();
        }
    }

    /**
     * Attempts to add a Logo to the document from the given resource. Returns
     * true on success and false on failure.
     *
     * @param doc The document to add the logo to. (Added to the top right
     * corner of the first page.
     * @param cb The DirectContent of the writer associated with the given
     * Document.
     * @param res The resource/path to the logo file. This file can be any of
     * the following formats:
     *  GIF, PNG, JPEG, PDF
     *
     * @return Succesfully added logo to document.
     */
    private boolean addLogoToDocumnet(Document doc, PdfWriter writer, String res) {
        boolean ret = false;
        try {
            //First we try to get the logo as if it is a Java Resource
            URL logoURL = this.getClass().getResource(res);
            log.debug(res + " -> " + logoURL.toString());
            if (logoURL == null) {
                logoURL = new URL(res);
            }

            if (logoURL != null) {
                String mtype = URLConnection.guessContentTypeFromStream(logoURL.openStream());
                if (mtype == null) {
                    mtype = URLConnection.guessContentTypeFromName(res);
                }
                log.debug("Determined MIMETYPE of logo: " + mtype);
                if (CitationPage.PDF_MIMES.contains(mtype)) {
                    //Handle pdf logos.
                    PdfReader reader = new PdfReader(logoURL);
                    PdfImportedPage logoPage = writer.getImportedPage(reader, 1);
                    Image logo = Image.getInstance(logoPage);
                    float x = doc.getPageSize().getWidth() - doc.rightMargin() - logo.getScaledWidth();
                    float y = doc.getPageSize().getHeight() - doc.topMargin() - logo.getScaledHeight();
                    logo.setAbsolutePosition(x, y);
                    doc.add(logo);
                    ret = true;
                } else if (CitationPage.RASTER_MIMES.contains(mtype)) {
                    //Use iText's Image class
                    Image logo = Image.getInstance(logoURL);

                    //Determine the position of the logo (upper-right corner) and
                    //place it there.
                    float x = doc.getPageSize().getWidth() - doc.rightMargin() - logo.getScaledWidth();
                    float y = doc.getPageSize().getHeight() - doc.topMargin() - logo.getScaledHeight();
                    logo.setAbsolutePosition(x, y);
                    writer.getDirectContent().addImage(logo);
                    ret = true;
                } else if (CitationPage.SVG_MIMES.contains(mtype)) {
                    //Handle SVG Logos
                    log.error("SVG Logos are not supported yet.");
                } else {
                    //Cannot use other mimetypes
                    log.debug("Logo MIMETYPE is not supported.");
                }
            } else {
                log.debug("Could not create URL to Logo resource: " + res);
            }
        } catch (Exception e) {
            log.error("Could not add logo (" + res + ") to cited document: "
                    + e.getMessage());
            ret = false;
        }
        return ret;
    }

    /**
     * A helper function for {@link CitationPage#performItem(Item)}. Creates a
     * cited document from the given bitstream of the given item. This
     * requires that bitstream is contained in item.
     * <p>
     * The Process for adding a cover page is as follows:
     * <ol>
     *  <li> Load source file into PdfReader and create a
     *     Document to put our cover page into.</li>
     *  <li> Create cover page and add content to it.</li>
     *  <li> Concatenate the coverpage and the source
     *     document.</li>
     * </p>
     *
     * @param bitstream The source bitstream being cited. This must be a PDF.
     * @param cMeta The citation information used to generate the coverpage.
     * @return The temporary File that is the finished, cited document.
     * @throws DocumentException
     * @throws FileNotFoundException
     * @throws SQLException
     * @throws AuthorizeException
     */
    private File makeCitedDocument(Bitstream bitstream, CitationMeta cMeta)
        throws FileNotFoundException, DocumentException, IOException,
               SQLException, AuthorizeException {
        //Read the source bitstream
        PdfReader source = new PdfReader(bitstream.retrieve());

        //Determine the size of the first page so the
        //citation page can be the same.
        Rectangle pdfSize = source.getCropBox(1);
        Document citedDoc = new Document(pdfSize);
        File coverTemp = File.createTempFile(
                bitstream.getName(), ".cover.pdf");
        //Need a writer instance to make changed to the
        //document.
        PdfWriter writer = PdfWriter.getInstance(citedDoc, new FileOutputStream(coverTemp));

        //Call helper function to add content to the coverpage.
        this.generateCoverPage(citedDoc, writer, cMeta);

        //Create reader from finished cover page.
        PdfReader cover = new PdfReader(
                new FileInputStream(coverTemp));

        //Get page labels from source document
        String[] labels = PdfPageLabels.getPageLabels(source);

        //Concatente the finished cover page with the source
        //document.
        File citedTemp = File.createTempFile(
                bitstream.getName(), ".cited.pdf");
        OutputStream citedOut = new FileOutputStream(citedTemp);
        PdfConcatenate concat = new PdfConcatenate(citedOut);
        concat.open();
        concat.addPages(source);
        concat.addPages(cover);

        //Put all of our labels in from the orignal document.
        if (labels != null) {
            PdfPageLabels citedPageLabels = new PdfPageLabels();
            log.debug("Printing arbitrary page labels.");

            for (int i = 0; i < labels.length; i++) {
                citedPageLabels.addPageLabel(i + 1, PdfPageLabels.EMPTY, labels[i]);
                log.debug("Label for page: " + (i + 1) + " -> " + labels[i]);
            }
            citedPageLabels.addPageLabel(labels.length + 1, PdfPageLabels.EMPTY, "Citation Page");
            concat.getWriter().setPageLabels(citedPageLabels);
        }

        //Close it up
        concat.close();

        return citedTemp;
    }

    /**
     * A helper function for {@link CitationPage#performItem(Item)}. This function takes in the
     * cited document as a File and adds it to DSpace properly.
     *
     * @param citedTemp The temporary File that is the cited document.
     * @param bundle The bundle the cited file is from.
     * @param pBundle The preservation bundle. The original document should be
     * put in here if it is not already.
     * @param dBundle The display bundle. The cited document gets put in here.
     * @param displayMap The map of bitstream names to bitstreams in the display
     * bundle.
     * @param item The item containing the bundles being used.
     * @param bitstream The original source bitstream.
     * @throws SQLException
     * @throws AuthorizeException
     * @throws IOException
     */
    private void addCitedPageToItem(File citedTemp, Bundle bundle, Bundle pBundle,
            Bundle dBundle, Map<String,Bitstream> displayMap, Item item,
            Bitstream bitstream) throws SQLException, AuthorizeException, IOException {
        //If we are modifying a file that is not in the
        //preservation bundle then we have to move it there.
        if (bundle.getID() != pBundle.getID()) {
            pBundle.addBitstream(bitstream);
            bundle.removeBitstream(bitstream);
            Bitstream[] originalBits = bundle.getBitstreams();
            if (originalBits == null || originalBits.length == 0) {
                item.removeBundle(bundle);
            }
        }

        //Create an input stream form the temporary file
        //that is the cited document and create a
        //bitstream from it.
        InputStream inp = new FileInputStream(citedTemp);
        if (displayMap.containsKey(bitstream.getName())) {
            dBundle.removeBitstream(displayMap.get(bitstream.getName()));
        }
        Bitstream citedBitstream = dBundle.createBitstream(inp);
        inp.close(); //Close up the temporary InputStream

        //Setup a good name for our bitstream and make
        //it the same format as the source document.
        citedBitstream.setName(bitstream.getName());
        citedBitstream.setFormat(bitstream.getFormat());
        citedBitstream.setDescription(bitstream.getDescription());

        this.resBuilder.append(" Added "
                + citedBitstream.getName()
                + " to the " + CitationPage.DISPLAY_BUNDLE_NAME + " bundle.\n");

        //Run update to propagate changes to the
        //database.
        item.update();
        this.status = Curator.CURATE_SUCCESS;
    }
}
