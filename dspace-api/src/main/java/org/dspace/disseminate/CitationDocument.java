package org.dspace.disseminate;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.Collection;
import org.dspace.content.DCValue;
import org.dspace.content.Item;
import org.dspace.core.ConfigurationManager;

import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * The Citation Document produces a dissemination package (DIP) that is different that the archival package (AIP).
 * In this case we append the descriptive metadata to the end (configurable) of the document. i.e. last page of PDF.
 * So instead of getting the original PDF, you get a cPDF (with citation information added).
 *
 * @author Peter Dietz (dietz.72@osu.edu)
 */
public class CitationDocument {
    /**
     * Class Logger
     */
    private static Logger log = Logger.getLogger(CitationDocument.class);

    /**
     * A set of MIME types that can have a citation page added to them. That is,
     * MIME types in this set can be converted to a PDF which is then prepended
     * with a citation page.
     */
    private static final Set<String> VALID_TYPES = new HashSet<String>(2);

    /**
     * A set of MIME types that refer to a PDF
     */
    private static final Set<String> PDF_MIMES = new HashSet<String>(2);

    /**
     * A set of MIME types that refer to a JPEG, PNG, or GIF
     */
    private static final Set<String> RASTER_MIMES = new HashSet<String>();
    /**
     * A set of MIME types that refer to a SVG
     */
    private static final Set<String> SVG_MIMES = new HashSet<String>();

    static {
        // Add valid format MIME types to set. This could be put in the Schema
        // instead.
        //Populate RASTER_MIMES
        SVG_MIMES.add("image/jpeg");
        SVG_MIMES.add("image/pjpeg");
        SVG_MIMES.add("image/png");
        SVG_MIMES.add("image/gif");
        //Populate SVG_MIMES
        SVG_MIMES.add("image/svg");
        SVG_MIMES.add("image/svg+xml");


        //Populate PDF_MIMES
        PDF_MIMES.add("application/pdf");
        PDF_MIMES.add("application/x-pdf");

        //Populate VALID_TYPES
        VALID_TYPES.addAll(PDF_MIMES);
    }

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


    public CitationDocument() {
    }
    
    public boolean canGenerateCitationVersion(Bitstream bitstream) {
        return VALID_TYPES.contains(bitstream.getFormat().getMIMEType());        
    }
    
    public File makeCitedDocument(Bitstream bitstream) {
        try {
        
            Item item = (Item) bitstream.getParentObject();
            CitationMeta cm = new CitationMeta(item);
            if(cm == null) {
                log.error("CitationMeta was null");
            }
            
            File citedDocumentFile = makeCitedDocument(bitstream, cm);
            if(citedDocumentFile == null) {
                log.error("Got a null citedDocumentFile in makeCitedDocument for bitstream");
            }
            return citedDocumentFile;
        } catch (Exception e) {
            log.error("makeCitedDocument from Bitstream fail!" + e.getMessage());
            return null;
        }
        
    }

    /**
     * Creates a
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
     * @throws com.itextpdf.text.DocumentException
     * @throws java.io.FileNotFoundException
     * @throws SQLException
     * @throws org.dspace.authorize.AuthorizeException
     */
    private File makeCitedDocument(Bitstream bitstream, CitationMeta cMeta)
            throws DocumentException, IOException, SQLException, AuthorizeException {
        //Read the source bitstream
        PdfReader source = new PdfReader(bitstream.retrieve());

        //Determine the size of the first page so the
        //citation page can be the same.
        Rectangle pdfSize = source.getCropBox(1);
        Document citedDoc = new Document(pdfSize);
        File coverTemp = File.createTempFile(bitstream.getName(), ".cover.pdf");

        //Need a writer instance to make changed to the document.
        PdfWriter writer = PdfWriter.getInstance(citedDoc, new FileOutputStream(coverTemp));

        //Call helper function to add content to the coverpage.
        this.generateCoverPage(citedDoc, writer, cMeta);

        //Create reader from finished cover page.
        PdfReader cover = new PdfReader(new FileInputStream(coverTemp));

        //Get page labels from source document
        String[] labels = PdfPageLabels.getPageLabels(source);

        //Concatente the finished cover page with the source document.
        File citedTemp = File.createTempFile(bitstream.getName(), ".cited.pdf");
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
    private void generateCoverPage(Document cDoc, PdfWriter writer, CitationMeta cMeta) throws DocumentException {
        cDoc.open();
        writer.setCompressionLevel(0);

        //Set up some fonts
        Font beforeAfterFont = FontFactory.getFont(FontFactory.TIMES_BOLD, 12f, new BaseColor(153, 0, 0));
        Font titleFont = FontFactory.getFont(FontFactory.TIMES_ROMAN, 30f, new BaseColor(0, 0, 0));
        Font headerFont = FontFactory.getFont(FontFactory.TIMES_ROMAN, 18f, new BaseColor(9, 9, 9));

        //Construct title and header paragraphs
        Paragraph title = new Paragraph(cMeta.getItem().getName(), titleFont);
        title.setLeading(0f, 1f);
        cDoc.add(title);

        Phrase beforeCollection = new Phrase(1f, "This file appeared in the following Collection:", beforeAfterFont);
        Paragraph fromPara = new Paragraph(beforeCollection);
        fromPara.setLeading(1f, 1.5f);
        cDoc.add(fromPara);

        Phrase collectionPhrase = new Phrase(1f, cMeta.getCollection().getName(), headerFont);
        Paragraph collectionPara = new Paragraph(collectionPhrase);
        collectionPara.setLeading(1f, 1.5f);
        cDoc.add(collectionPara);

        //Add OSU logo to citation page.
        if (LOGO_RESOURCE.length() > 0) {
            if (!this.addLogoToDocument(cDoc, writer, LOGO_RESOURCE)) {
                log.debug("Unable to add logo from " + LOGO_RESOURCE);
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
     * Attempts to add a Logo to the document from the given resource. Returns
     * true on success and false on failure.
     *
     * @param doc The document to add the logo to. (Added to the top right
     * corner of the first page.
     * @param writer The writer associated with the given Document.
     * @param res The resource/path to the logo file. This file can be any of
     * the following formats:
     *  GIF, PNG, JPEG, PDF
     *
     * @return Succesfully added logo to document.
     */
    private boolean addLogoToDocument(Document doc, PdfWriter writer, String res) {
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
                if (PDF_MIMES.contains(mtype)) {
                    //Handle pdf logos.
                    PdfReader reader = new PdfReader(logoURL);
                    PdfImportedPage logoPage = writer.getImportedPage(reader, 1);
                    Image logo = Image.getInstance(logoPage);
                    float x = doc.getPageSize().getWidth() - doc.rightMargin() - logo.getScaledWidth();
                    float y = doc.getPageSize().getHeight() - doc.topMargin() - logo.getScaledHeight();
                    logo.setAbsolutePosition(x, y);
                    doc.add(logo);
                    ret = true;
                } else if (RASTER_MIMES.contains(mtype)) {
                    //Use iText's Image class
                    Image logo = Image.getInstance(logoURL);

                    //Determine the position of the logo (upper-right corner) and
                    //place it there.
                    float x = doc.getPageSize().getWidth() - doc.rightMargin() - logo.getScaledWidth();
                    float y = doc.getPageSize().getHeight() - doc.topMargin() - logo.getScaledHeight();
                    logo.setAbsolutePosition(x, y);
                    writer.getDirectContent().addImage(logo);
                    ret = true;
                } else if (SVG_MIMES.contains(mtype)) {
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
         * @throws java.sql.SQLException
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

}
