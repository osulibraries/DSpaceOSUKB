/*
 * METSRightsCrosswalk.java
 *
 * Version: $Revision: 5265 $
 *
 * Date: $Date: 2010-08-13 15:10:32 -0500 (Fri, 13 Aug 2010) $
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

package org.dspace.content.crosswalk;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.authorize.ResourcePolicy;
import org.dspace.content.DSpaceObject;
import org.dspace.content.packager.PackageException;
import org.dspace.content.packager.PackageUtils;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;
import org.dspace.eperson.Group;
import org.jdom.Element;
import org.jdom.Namespace;

/**
 * METSRights Ingestion & Dissemination Crosswalk
 * <p>
 * Translate between DSpace internal policies (i.e. permissions) and the
 * METSRights metadata schema
 * (see <a href="http://www.loc.gov/standards/rights/METSRights.xsd">
 * http://www.loc.gov/standards/rights/METSRights.xsd</a> for details).
 * <p>
 * Examples of METSRights usage available from:
 * <a href="http://www.loc.gov/standards/rights/">
 * http://www.loc.gov/standards/rights/</a>
 * <p>
 * This Crosswalk provides a way to export DSpace permissions into a standard
 * format, and then re-import or restore them into a DSpace instance.
 *
 * @author Tim Donohue
 * @version $Revision: 2108 $
 */
public class METSRightsCrosswalk 
    implements IngestionCrosswalk, DisseminationCrosswalk
{
    /** log4j category */
    private static Logger log = Logger.getLogger(METSRightsCrosswalk.class);

    private static final Namespace METSRights_NS =
        Namespace.getNamespace("rights", "http://cosimo.stanford.edu/sdr/metsrights/");

    // XML schemaLocation fragment for this crosswalk, from config.
    private String schemaLocation =
        METSRights_NS.getURI()+" http://cosimo.stanford.edu/sdr/metsrights.xsd";

    private static final Namespace namespaces[] = { METSRights_NS };

    private final static Map<Integer,String> otherTypesMapping = new HashMap<Integer,String>();
    static
    {
        //Mapping of DSpace Policy Actions to METSRights PermissionType values
        // (These are the values stored in the @OTHERPERMITTYPE attribute in METSRights)
        // NOTE: READ, WRITE, DELETE are not included here as they map directly to existing METSRights PermissionTypes
        otherTypesMapping.put(Constants.ADD, "ADD CONTENTS");
        otherTypesMapping.put(Constants.REMOVE, "REMOVE CONTENTS");
        otherTypesMapping.put(Constants.ADMIN, "ADMIN");
        otherTypesMapping.put(Constants.DEFAULT_BITSTREAM_READ, "READ FILE CONTENTS");
        otherTypesMapping.put(Constants.DEFAULT_ITEM_READ, "READ ITEM CONTENTS");
    }

    // Value of METSRights <Context> @CONTEXTCLASS attribute to use for DSpace Groups
    private static final String GROUP_CONTEXTCLASS = "MANAGED GRP";
    // Value of METSRights <Context> @CONTEXTCLASS attribute to use for DSpace EPeople
    private static final String PERSON_CONTEXTCLASS = "ACADEMIC USER";
    // Value of METSRights <Context> @CONTEXTCLASS attribute to use for "Anonymous" DSpace Group
    private static final String ANONYMOUS_CONTEXTCLASS = "GENERAL PUBLIC";
    // Value of METSRights <Context> @CONTEXTCLASS attribute to use for "Administrator" DSpace Group
    private static final String ADMIN_CONTEXTCLASS = "REPOSITORY MGR";
    // Value of METSRights <UserName> @USERTYPE attribute to use for DSpace Groups
    private static final String GROUP_USERTYPE = "GROUP";
    // Value of METSRights <UserName> @USERTYPE attribute to use for DSpace Groups
    private static final String PERSON_USERTYPE = "INDIVIDUAL";


    /*----------- Dissemination functions -------------------*/

    @Override
    public Namespace[] getNamespaces()
    {
        return namespaces;
    }

    @Override
    public String getSchemaLocation()
    {
        return schemaLocation;
    }

    @Override
    public boolean canDisseminate(DSpaceObject dso)
    {
        //can disseminate all types of DSpace Objects, except for SITE
        if(dso.getType()!=Constants.SITE)
            return true;
        else
            return false;
    }

    /**
     * Actually Disseminate into METSRights schema.  This method locates all DSpace
     * policies (permissions) for the provided object, and translates them into
     * METSRights PermissionTypes.
     *
     * @param dso DSpace Object
     * @return XML Element corresponding to the new <RightsDeclarationMD> translation
     * @throws CrosswalkException
     * @throws IOException
     * @throws SQLException
     * @throws AuthorizeException
     */
    @Override
    public Element disseminateElement(DSpaceObject dso)
        throws CrosswalkException,
               IOException, SQLException, AuthorizeException
    {
        if(dso==null)
            return null;
        // we don't have a way to provide METSRights for a SITE object
        else if(dso.getType() == Constants.SITE)
            throw new CrosswalkObjectNotSupported("The METSRightsCrosswalk cannot crosswalk a SITE object");


        //Root element: RightsDeclarationMD
        // All DSpace content is just under LICENSE -- no other rights can be claimed
        Element rightsMD = new Element("RightsDeclarationMD", METSRights_NS);
        rightsMD.setAttribute("RIGHTSCATEGORY", "LICENSED");

        //Three sections to METSRights:
        // * RightsDeclaration - general rights statement
        // * RightsHolder - info about who owns rights
        // * Context - info about specific permissions granted
        // We're just crosswalking DSpace policies to "Context" permissions by default
        // It's too difficult to make statements about who owns the rights and
        // what those rights are -- too many types of content can be stored in DSpace

        //Get all policies on this DSpace Object
        Context context = new Context();
        List<ResourcePolicy> policies = AuthorizeManager.getPolicies(context, dso);

        //For each DSpace policy
        for(ResourcePolicy policy : policies)
        {
           // DSpace Policies can either reference a Group or an Individual, but not both!
           Group group = policy.getGroup();
           EPerson person = policy.getEPerson();

           // Create our <Context> node for this policy
           Element rightsContext = new Element("Context", METSRights_NS);
           rightsMD.addContent(rightsContext);

  
           //First, handle Group-based policies
           // For Group policies we need to setup a
           // <Context CONTEXTCLASS='[group-type]'><UserName USERTYPE='GROUP'>[group-name]</UserName>...
           if(group != null)
           {
              //Default all DSpace groups to have "MANAGED GRP" as the type
              String contextClass=GROUP_CONTEXTCLASS;

              if(group.getID()==0) //DSpace Anonymous Group = 'GENERAL PUBLIC' type
                contextClass = ANONYMOUS_CONTEXTCLASS;
              else if(group.getID()==1) //DSpace Administrator Group = 'REPOSITORY MGR' type
                contextClass = ADMIN_CONTEXTCLASS;

              rightsContext.setAttribute("CONTEXTCLASS", contextClass);

              //If this is a "MANAGED GRP", then create a <UserName> child
              //to specify the group Name, and set @USERTYPE='GROUP'
              if(contextClass.equals(GROUP_CONTEXTCLASS))
              {
                  try
                  {
                      //Create <UserName USERTYPE='GROUP'> element.  Add the Group's name to that element
                      // But first, make sure to crosswalk all DSpace Default Group names:
                      // e.g. translate COLLECTION_<ID>_ADMIN to COLLECTION_<handle>_ADMIN ,
                      // as internal IDs are meaningless once content is outside of DSpace
                      Element rightsUser = new Element("UserName", METSRights_NS);
                      rightsUser.setAttribute("USERTYPE",GROUP_USERTYPE);
                      rightsUser.addContent(PackageUtils.translateGroupNameForExport(context, group.getName()));
                      rightsContext.addContent(rightsUser);
                  }
                  catch(PackageException pe)
                  {
                      //A PackageException will only be thrown if translateGroupNameForExport() fails
                      //We'll just wrap it as a CrosswalkException and throw it upwards
                      throw new CrosswalkException(pe);
                  }
              }
           }//end if group
           //Next, handle User-based policies
           // For User policies we need to setup a
           // <Context CONTEXTCLASS='ACADEMIC USER'><UserName USERTYPE='INDIVIDUAL'>[group-name]</UserName>...
           else if(person!=null)
           {
              // All EPeople are considered 'Academic Users'
              rightsContext.setAttribute("CONTEXTCLASS", PERSON_CONTEXTCLASS);

              //Create a <UserName> node corresponding to person's email, set @USERTYPE='INDIVIDUAL'
              Element rightsUser = new Element("UserName", METSRights_NS);
              rightsUser.setAttribute("USERTYPE",PERSON_USERTYPE);
              rightsUser.addContent(person.getEmail());
              rightsContext.addContent(rightsUser);
           }//end if person


           //Translate the DSpace ResourcePolicy into a <Permissions> element
           Element rightsPerm = translatePermissions(policy);
           rightsContext.addContent(rightsPerm);
           
        }//end for each policy

        context.complete();
        return rightsMD;
    }

    @Override
    public List disseminateList(DSpaceObject dso)
        throws CrosswalkException,
               IOException, SQLException, AuthorizeException
    {
        List result = new ArrayList(1);
        result.add(disseminateElement(dso));
        return result;
    }

    @Override
    public boolean preferList()
    {
        return false;
    }


    /**
     * Translates a DSpace ResourcePolicy's permissions into a METSRights
     * <code>Permissions</code> element. Returns the created
     * <code>Permissions</code> element. This element may be empty if
     * there was an issue translating the ResourcePolicy.
     *
     * @param policy  The DSpace ResourcePolicy
     * @return the Element representing the METSRIghts <code>Permissions</code> or null.
     */
    private Element translatePermissions(ResourcePolicy policy)
    {
        //Create our <Permissions> node to store all permissions in this context
        Element rightsPerm = new Element("Permissions", METSRights_NS);

        //Determine the 'actions' permitted by this DSpace policy, and translate to METSRights PermissionTypes
        int action = policy.getAction();
        //All READ-based actions = cannot modify or delete object
        if(action==Constants.READ
                || action==Constants.DEFAULT_BITSTREAM_READ
                || action==Constants.DEFAULT_ITEM_READ)
        {
             // For DSpace, READ = Discover and Display
             rightsPerm.setAttribute("DISCOVER", "true");
             rightsPerm.setAttribute("DISPLAY", "true");
             //Read = cannot modify or delete
             rightsPerm.setAttribute("MODIFY", "false");
             rightsPerm.setAttribute("DELETE", "false");
        }
        //All WRITE-based actions = can modify, but cannot delete
        else if(action == Constants.WRITE
                || action==Constants.ADD)
        {
            rightsPerm.setAttribute("DISCOVER", "true");
            rightsPerm.setAttribute("DISPLAY", "true");
            //Write = can modify, but cannot delete
            rightsPerm.setAttribute("MODIFY", "true");
            rightsPerm.setAttribute("DELETE", "false");
        }
        //All DELETE-based actions = can modify & can delete
        //(NOTE: Although Constants.DELETE is marked as "obsolete", it is still used in dspace-api)
        else if(action == Constants.DELETE
                || action==Constants.REMOVE)
        {
            rightsPerm.setAttribute("DISCOVER", "true");
            rightsPerm.setAttribute("DISPLAY", "true");
            //Delete = can both modify and delete
            rightsPerm.setAttribute("MODIFY", "true");
            rightsPerm.setAttribute("DELETE", "true");
        }
        //ADMIN action = full permissions
        else if(action == Constants.ADMIN)
        {
            rightsPerm.setAttribute("DISCOVER", "true");
            rightsPerm.setAttribute("DISPLAY", "true");
            rightsPerm.setAttribute("COPY", "true");
            rightsPerm.setAttribute("DUPLICATE", "true");
            rightsPerm.setAttribute("MODIFY", "true");
            rightsPerm.setAttribute("DELETE", "true");
            rightsPerm.setAttribute("PRINT", "true");
        }
        else
        {
            //Unknown action -- don't enable any rights by default
            //NOTE: ALL WORKFLOW RELATED ACTIONS ARE NOT INCLUDED IN METSRIGHTS
            //DSpace API no longer assigns nor checks any of the following 'action' types:
            // * Constants.WORKFLOW_STEP_1
            // * Constants.WORKFLOW_STEP_2
            // * Constants.WORKFLOW_STEP_3
            // * Constants.WORKFLOW_ABORT
        }//end if

        //Also add in OTHER permissionTypes, as necessary (see 'otherTypesMapping' above)
        // (These OTHER permissionTypes are used to tell apart similar DSpace permissions during Ingestion)
        if(otherTypesMapping.containsKey(action))
        {
            //if found in our 'otherTypesMapping', enable @OTHER attribute and add in the appropriate value to @OTHERPERMITTYPE attribute
            rightsPerm.setAttribute("OTHER", "true");
            rightsPerm.setAttribute("OTHERPERMITTYPE", otherTypesMapping.get(action));
        }

        return rightsPerm;
    }


    /*----------- Ingestion functions -------------------*/

    /**
     * Ingest a whole XML document, starting at specified root.
     *
     * @param context
     * @param dso
     * @param root
     * @throws CrosswalkException
     * @throws IOException
     * @throws SQLException
     * @throws AuthorizeException
     */
    @Override
    public void ingest(Context context, DSpaceObject dso, Element root)
        throws CrosswalkException, IOException, SQLException, AuthorizeException
    {
        if (!(root.getName().equals("RightsDeclarationMD")))
            throw new MetadataValidationException("Wrong root element for METSRights: "+root.toString());
        ingest(context, dso, root.getChildren());
    }

    /**
     * Ingest a List of XML elements
     * <P>
     * This method creates new DSpace Policies based on the parsed
     * METSRights XML contents. These Policies assign permissions
     * to DSpace Groups or EPeople.
     * <P>
     * NOTE: This crosswalk will NOT create missing DSpace Groups or EPeople.
     * Therefore, it is recommended to use this METSRightsCrosswalk in
     * conjunction with another Crosswalk which can create/restore missing
     * Groups or EPeople (e.g. RoleCrosswalk).
     *
     * @param context
     * @param dso
     * @param metadata
     * @throws CrosswalkException
     * @throws IOException
     * @throws SQLException
     * @throws AuthorizeException
     * @see RoleCrosswalk
     */
    @Override
    public void ingest(Context context, DSpaceObject dso, List ml)
        throws CrosswalkException, IOException, SQLException, AuthorizeException
    {
        // we cannot crosswalk METSRights to a SITE object
        if (dso.getType() == Constants.SITE)
            throw new CrosswalkObjectNotSupported("Wrong target object type, METSRightsCrosswalk cannot crosswalk a SITE object.");

        //First, clear all existing Policies on this DSpace Object
        // as we don't want them to conflict with policies we will be adding
        if(!ml.isEmpty())
            AuthorizeManager.removeAllPolicies(context, dso);

        // Loop through each Element in the List
        Iterator mi = ml.iterator();
        while (mi.hasNext())
        {
            Element element = (Element)mi.next();

            // if we're fed a <RightsDeclarationMD> wrapper object, recurse on its guts:
            if (element.getName().equals("RightsDeclarationMD"))
                ingest(context, dso, element.getChildren());
            // "Context" section (where permissions are stored)
            else if (element.getName().equals("Context"))
            {
                //get what class of context this is
                String contextClass = element.getAttributeValue("CONTEXTCLASS");

                //also get reference to the <Permissions> element
                Element permsElement = element.getChild("Permissions", METSRights_NS);

                //Check if this permission pertains to Anonymous users
                if(contextClass.equals(ANONYMOUS_CONTEXTCLASS))
                {
                    //get DSpace Anonymous group, ID=0
                    Group anonGroup = Group.find(context, 0);
                    if(anonGroup==null)
                        throw new CrosswalkInternalException("The DSpace database has not been properly initialized.  The Anonymous Group is missing from the database.");

                    assignPermissions(context, dso, anonGroup, permsElement);
                } // else if this permission declaration pertains to Administrators
                else if(contextClass.equals(ADMIN_CONTEXTCLASS))
                {
                    //get DSpace Administrator group, ID=1
                    Group adminGroup = Group.find(context, 1);
                    if(adminGroup==null)
                        throw new CrosswalkInternalException("The DSpace database has not been properly initialized.  The Administrator Group is missing from the database.");

                    assignPermissions(context, dso, adminGroup, permsElement);
                } // else if this permission pertains to another DSpace group
                else if(contextClass.equals(GROUP_CONTEXTCLASS))
                {
                    try
                    {
                        //we need to find the name of DSpace group it pertains to
                        //Get the text within the <UserName> child element,
                        // this is the group's name
                        String groupName = element.getChildTextTrim("UserName", METSRights_NS);

                        //Translate Group name back to internal ID format (e.g. COLLECTION_<ID>_ADMIN)
                        // from its external format (e.g. COLLECTION_<handle>_ADMIN)
                        groupName = PackageUtils.translateGroupNameForImport(context, groupName);

                        //Check if this group exists in DSpace already
                        Group group = Group.findByName(context, groupName);

                        //if not found, throw an error -- user should restore group from the SITE AIP
                        if(group==null)
                        {
                            throw new CrosswalkInternalException("Cannot restore Group permissions on object ("
                                    + "type=" + Constants.typeText[dso.getType()] + ", "
                                    + "handle=" + dso.getHandle() + ", "
                                    + "ID=" + dso.getID()
                                    + "). The Group named '" + groupName + "' is missing from DSpace. "
                                    + "Please restore this group using the SITE AIP, or recreate it.");
                        }

                        //assign permissions to group on this object
                        assignPermissions(context, dso, group, permsElement);
                    }
                    catch(PackageException pe)
                    {
                        //A PackageException will only be thrown if translateDefaultGroupName() fails
                        //We'll just wrap it as a CrosswalkException and throw it upwards
                        throw new CrosswalkException(pe);
                    }
                }//end if Group
                else if(contextClass.equals(PERSON_CONTEXTCLASS))
                {
                    //we need to find the person it pertains to
                    // Get the text within the <UserName> child element,
                    // this is the person's email address
                    String personEmail = element.getChildTextTrim("UserName", METSRights_NS);

                    //Check if this person exists in DSpace already
                    EPerson person = EPerson.findByEmail(context, personEmail);

                    //If cannot find by email, try by netID
                    //(though METSRights should contain email if it was exported by DSpace)
                    if(person==null)
                        person = EPerson.findByNetid(context, personEmail);

                    //if not found, throw an error -- user should restore person from the SITE AIP
                    if(person==null)
                    {
                        throw new CrosswalkInternalException("Cannot restore Person permissions on object ("
                                + "type=" + Constants.typeText[dso.getType()] + ", "
                                + "handle=" + dso.getHandle() + ", "
                                + "ID=" + dso.getID()
                                + "). The Person with email/netid '" + personEmail + "' is missing from DSpace. "
                                + "Please restore this Person object using the SITE AIP, or recreate it.");
                    }

                    //assign permissions to person on this object
                    assignPermissions(context, dso, person, permsElement);
                }//end if Person
            } //end if "Context" element
        }//end while loop
    }


    /**
     * Parses the 'permsElement' (corresponding to a <code>Permissions</code>
     * element), and assigns those permissions to the specified Group
     * on the specified DSpace Object.
     *
     * @param context DSpace context object
     * @param dso The DSpace Object
     * @param group The DSpace Group
     * @param permsElement The METSRights <code>Permissions</code> element
     */
    private void assignPermissions(Context context, DSpaceObject dso, Group group, Element permsElement)
            throws SQLException, AuthorizeException
    {
        //first, parse our permissions to determine which action we are allowing in DSpace
        int actionID = parsePermissions(permsElement);

        //If action ID is less than base READ permissions (value=0),
        // then something must've gone wrong in the parsing
        if(actionID < Constants.READ)
        {
            log.warn("Unable to properly restore all access permissions on object ("
                        + "type=" + Constants.typeText[dso.getType()] + ", "
                        + "handle=" + dso.getHandle() + ", "
                        + "ID=" + dso.getID()
                        + ") for group '" + group.getName() + "'.");
        }

        //Otherwise, add the appropriate group policy for this object
        AuthorizeManager.addPolicy(context, dso, actionID, group);
    }

     /**
     * Parses the 'permsElement' (corresponding to a <code>Permissions</code>
     * element), and assigns those permissions to the specified EPerson
     * on the specified DSpace Object.
     *
     * @param context DSpace context object
     * @param dso The DSpace Object
     * @param person The DSpace EPerson
     * @param permsElement The METSRights <code>Permissions</code> element
     */
    private void assignPermissions(Context context, DSpaceObject dso, EPerson person, Element permsElement)
            throws SQLException, AuthorizeException
    {
        //first, parse our permissions to determine which action we are allowing in DSpace
        int actionID = parsePermissions(permsElement);

        //If action ID is less than base READ permissions (value=0),
        // then something must've gone wrong in the parsing
        if(actionID < Constants.READ)
        {
            log.warn("Unable to properly restore all access permissions on object ("
                        + "type=" + Constants.typeText[dso.getType()] + ", "
                        + "handle=" + dso.getHandle() + ", "
                        + "ID=" + dso.getID()
                        + ") for person '" + person.getEmail() + "'.");
        }

        //Otherwise, add the appropriate EPerson policy for this object
        AuthorizeManager.addPolicy(context, dso, actionID, person);
    }

    /**
     * Parses the 'permsElement' (corresponding to a <code>Permissions</code>
     * element) to find the corresponding DSpace permission type.  This
     * DSpace permission type must be one of the Action IDs specified in
     * <code>org.dspace.core.Constants</code>
     * <P>
     * Returns -1 if failed to parse permissions.
     *
     * @param permsElement The METSRights <code>Permissions</code> element
     * @return A DSpace Action ID from <code>org.dspace.core.Constants</code>
     */
    private int parsePermissions(Element permsElement)
    {
        //First, check if the @OTHERPERMITTYPE attribute is specified
        String otherPermitType = permsElement.getAttributeValue("OTHERPERMITTYPE");

        //if @OTHERPERMITTYPE attribute exists, it will map directly to a DSpace Action type
        if(otherPermitType!=null && !otherPermitType.isEmpty())
        {
            if(otherTypesMapping.containsValue(otherPermitType))
            {
                //find the Action ID this value maps to
                for(int actionType: otherTypesMapping.keySet())
                {
                    //if found, this is the Action ID corresponding to this permission
                    if(otherTypesMapping.get(actionType).equals(otherPermitType))
                        return actionType;
                }
            }
            else
            {
                log.warn("Unrecognized @OTHERPERMITTYPE attribute value ("
                            + otherPermitType
                            + ") found in METSRights section of METS Manifest.");
            }
        }
        else // Otherwise, a closer analysis of all Permission element attributes is necessary
        {
            boolean discoverPermit = Boolean.parseBoolean(permsElement.getAttributeValue("DISCOVER"));
            boolean displayPermit = Boolean.parseBoolean(permsElement.getAttributeValue("DISPLAY"));
            boolean modifyPermit = Boolean.parseBoolean(permsElement.getAttributeValue("MODIFY"));
            boolean deletePermit = Boolean.parseBoolean(permsElement.getAttributeValue("DELETE"));
            boolean otherPermit = Boolean.parseBoolean(permsElement.getAttributeValue("OTHER"));

            //if DELETE='true'
            if(deletePermit && !otherPermit)
            {
                //This must refer to the DELETE action type
                //(note REMOVE & ADMIN action type have @OTHERPERMITTYPE values specified)
                return Constants.DELETE;
            }//if MODIFY='true'
            else if(modifyPermit && !otherPermit)
            {
                //This must refer to the WRITE action type
                //(note ADD action type has an @OTHERPERMITTYPE value specified)
                return Constants.WRITE;
            }
            else if(discoverPermit && displayPermit && !otherPermit)
            {
                //This must refer to the READ action type
                return Constants.READ;
            }
        }

        //if we got here, we failed to parse out proper permissions
        // return -1 to signify failure (as 0 = READ permissions)
        return -1;
    }
}
