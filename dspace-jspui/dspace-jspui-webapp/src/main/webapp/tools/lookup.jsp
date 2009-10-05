<%--
  - lookup.jsp
  -
  - Version: $Revision: 3705 $
  -
  - Date: $Date: 2009-04-11 13:02:24 -0400 (Sat, 11 Apr 2009) $
  -
  - Copyright (c) 2002, Hewlett-Packard Company and Massachusetts
  - Institute of Technology.  All rights reserved.
  -
  - Redistribution and use in source and binary forms, with or without
  - modification, are permitted provided that the following conditions are
  - met:
  -
  - - Redistributions of source code must retain the above copyright
  - notice, this list of conditions and the following disclaimer.
  -
  - - Redistributions in binary form must reproduce the above copyright
  - notice, this list of conditions and the following disclaimer in the
  - documentation and/or other materials provided with the distribution.
  -
  - - Neither the name of the Hewlett-Packard Company nor the name of the
  - Massachusetts Institute of Technology nor the names of their
  - contributors may be used to endorse or promote products derived from
  - this software without specific prior written permission.
  -
  - THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  - ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  - LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  - A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  - HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  - INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  - BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
  - OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  - ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  - TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
  - USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  - DAMAGE.
  --%>

<%--
  - Form requesting a Handle or internal item ID for item editing
  -
  - Attributes:
  -     invalid.id  - if this attribute is present, display error msg
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.jsp.tagext.TagSupport" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.ServletException" %>

<%@ page import="org.dspace.core.ConfigurationManager" %>

<%-- invoke "popup" style which elides all the header and footer stuff.
    --%>
<%!
    // get request parameter but return a default value if not present.
    String getDefaultedRequestParameter(HttpServletRequest r, String param, String dflt)
    {
        String result = r.getParameter(param);
        return (result == null) ? dflt : result;
    }
%>
<%
    String mdfield = getDefaultedRequestParameter(request,"field", "FieldMissing");
    String isNameValue = getDefaultedRequestParameter(request,"isName", "false");
    String isRepeatingValue = getDefaultedRequestParameter(request,"isRepeating", "false");
    boolean isName = isNameValue.equalsIgnoreCase("true");
    boolean isRepeating = isRepeatingValue.equalsIgnoreCase("true");
%>

<dspace:layout titlekey="jsp.tools.lookup.title"
               style="popup"
               navbar="off"
               locbar="off"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">

        <h1><%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.field."+mdfield+".title") %></h1>

  <form id="aspect_general_ChoiceLookupTransformer_div_lookup"
        class="ds-interactive-div popup" action="" method="get">
    <fieldset id="aspect_general_ChoiceLookupTransformer_list_choicesList"
              class="ds-form-list choices-lookup">

            <%-- Results @1@ to @2@ of @3@ for "@4@" --%>
    <legend><fmt:message key="jsp.tools.lookup.results"/></legend>
    <ol>
      <li id="aspect_general_ChoiceLookupTransformer_item_select" class="ds-form-item choices-lookup"> 
        <div class="ds-form-content">
          <div>
            <select onChange="javascript:DSpaceChoicesSelectOnChange();" id="aspect_general_ChoiceLookupTransformer_field_chooser" class="ds-select-field choices-lookup" name="chooser"
             size="<%= String.valueOf(ConfigurationManager.getIntProperty("webui.lookup.select.size", 12)) %>">
             <!--space filler because "unclosed" select annoys browsers-->
            </select>
            <img style="display:none;" alt="Loading..." id="lookup_indicator_id" class="choices-lookup"
              src="<%= request.getContextPath() %>/image/authority/load-indicator.gif" />
          </div>
          <input type="hidden" name="paramField"          value="<%= getDefaultedRequestParameter(request,"field", "") %>" />
          <input type="hidden" name="paramValue"          value="<%= getDefaultedRequestParameter(request,"value", "") %>" />
          <input type="hidden" name="paramIsName"         value="<%= isNameValue %>" />
          <input type="hidden" name="paramIsRepeating"    value="<%= isRepeatingValue %>" />
          <input type="hidden" name="paramValueInput"     value="<%= getDefaultedRequestParameter(request,"valueInput", "") %>" />
          <input type="hidden" name="paramAuthorityInput" value="<%= getDefaultedRequestParameter(request,"authorityInput", "") %>" />
          <input type="hidden" name="paramStart"          value="<%= getDefaultedRequestParameter(request,"start", "0") %>" />
          <input type="hidden" name="paramLimit"          value="<%= getDefaultedRequestParameter(request,"limit", "0") %>" />
          <input type="hidden" name="paramFormID"         value="<%= getDefaultedRequestParameter(request,"formID", "") %>" />
          <input type="hidden" name="paramIsClosed"       value="<%= getDefaultedRequestParameter(request,"isClosed", "false") %>" />
          <input type="hidden" name="paramConfIndicatorID" value="<%= getDefaultedRequestParameter(request,"confIndicatorID", "") %>" />
          <input type="hidden" name="paramCollection"      value="<%= getDefaultedRequestParameter(request,"collection", "-1") %>" />

          <%-- XXX get this from dspace config if available..?? --%>
          <input type="hidden" name="paramNonAuthority"   value="<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.field."+mdfield+".nonauthority") %>" />

          <input name="paramFail" type="hidden" value="<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.fail") %>" />
          <input name="contextPath" type="hidden" value="<%= request.getContextPath() %>" />
        </div>
      </li>
      <li id="aspect_general_ChoiceLookupTransformer_item_textFields" class="ds-form-item choices-lookup"> 
        <div class="ds-form-content">

          <% if (isName) { %>
          <%-- XXX get this from dspace config if available..?? --%>
            <% String help1 = LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.field."+mdfield+".help.last"); %>
            <% String help2 = LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.field."+mdfield+".help.first"); %>
            <label class="ds-composite-component">
              <input class="ds-text-field choices-lookup" name="text1" type="text" value=""
                  title="<%= help1 %>" />
              <br/><%= help1 %>
            </label>
            <label class="ds-composite-component last">
              <input class="ds-text-field choices-lookup" name="text2" type="text" value=""
                  title="<%= help2 %>" />
              <br/><%= help2 %>
            </label>
          <% } else { %>
          <%-- XXX get this from dspace config if available..?? --%>
            <% String help = LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.field."+mdfield+".help"); %>
            <label class="ds-composite-component">
              <input class="ds-text-field choices-lookup" name="text1" type="text" value=""
                  title="<%= help %>" />
              <br/><%= help %>
            </label>
          <% } %>
          <div class="spacer"> </div>
        </div>
      </li>
      <li class="ds-form-item last choices-lookup"> 
        <div class="ds-form-content">
          <input name="accept"  onClick="javascript:DSpaceChoicesAcceptOnClick();" type="button" class="ds-button-field choices-lookup"
                value="<%= LocaleSupport.getLocalizedMessage(pageContext, isRepeating ? "jsp.tools.lookup.add":"jsp.tools.lookup.accept") %>"/>
          <input name="more"  onClick="javascript:DSpaceChoicesMoreOnClick();" type="button"   class="ds-button-field choices-lookup" disabled="disabled"
                value="<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.more") %>"/>
          <input name="cancel"  onClick="javascript:DSpaceChoicesCancelOnClick();" type="button" class="ds-button-field choices-lookup"
                value="<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.cancel") %>"/>
        </div>
      </li>
    </ol>
  </fieldset>
</form>
<script type="text/javascript">
        var form = document.getElementById('aspect_general_ChoiceLookupTransformer_div_lookup');
        DSpaceChoicesSetup(form);
</script>
</dspace:layout>
