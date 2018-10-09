<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:l="http://xproc.org/library" type="f:convert" name="main" version="1.0">
  
  <p:option name="target" select="'../../../target/'"/>
  <p:option name="_target" select="resolve-uri($target)"/>
  <p:option name="xmlroot" select="'../../../data/xml'"></p:option>
  <p:option name="_xmlroot" select="resolve-uri($xmlroot)"/>
  
  <p:input port="source"><p:empty/></p:input>
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result" primary="true" sequence="true"><p:empty/></p:output>
  <p:serialization port="result" indent="true"/>
  
  <p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <cx:message message="Collecting metadata ..."></cx:message>
  
  <l:recursive-directory-list name="metadata"> 
    <p:with-option name="path" select="concat($_xmlroot, '/document')"/>
  </l:recursive-directory-list>
  
  <p:for-each name="metadata-extracts">
    <p:iteration-source select="//c:file">
      <p:pipe port="result" step="metadata"/>
    </p:iteration-source>
    <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
    <p:variable name="relative-doc" select="replace($filename, $_xmlroot, '')"/>
    <p:load>
      <p:with-option name="href" select="$filename"/>
    </p:load>
    <p:xslt>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.faustedition.net/ns"
            exclude-result-prefixes="#all">
            <xsl:param name="href"/>
            <xsl:template match="/">
              <document href="{$href}" xmlns="http://www.faustedition.net/ns">
                <xsl:for-each select="descendant::textTranscript[@uri]|descendant::docTranscript[@uri]">
                  <xsl:copy copy-namespaces="no">
                    <xsl:attribute name="uri" select="resolve-uri(@uri, base-uri(.))"/>
                  </xsl:copy>
                </xsl:for-each>
                <xsl:copy-of select="descendant::idno|descendant::repository" copy-namespaces="no"/>
              </document>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:with-param name="href" select="$relative-doc"/>
    </p:xslt>
  </p:for-each>
  
  <p:wrap-sequence wrapper="f:documents"/>
  
  <p:store name="save-metadata" indent="true">
    <p:with-option name="href" select="p:resolve-uri('selected-metadata.xml', $_target)"/>
  </p:store>
  
  <cx:message>
    <p:with-option name="message" select="concat('Collected metadata in ', p:resolve-uri('selected-metadata.xml', $_target))"/>
    <p:input port="source"><p:pipe port="result" step="save-metadata"/></p:input>
  </cx:message>
  
  <p:sink/>
    
  
  <p:load href="http://dev.digital-humanities.de/ci/job/faust-gen-fast/lastSuccessfulBuild/artifact/target/lesetext/faust.xml"/>
  <cx:message message="Fetched reading text"/>
  <p:store name="save-text"> <!-- does not need conversion -->
    <p:with-option name="href" select="concat($_target, '/converted/faust.xml')"/>
  </p:store>
  
  <l:recursive-directory-list name="transcript"> <!-- exclude-filter="test" --> 
    <p:with-option name="path" select="concat($_xmlroot, '/transcript')"/>
  </l:recursive-directory-list>
  
  <l:recursive-directory-list name="print"> 
    <p:with-option name="path" select="concat($_xmlroot, '/print')"/>
  </l:recursive-directory-list>
  
  
  
  <p:for-each cx:after="save-metadata">
    <p:iteration-source select="//c:file">
      <p:pipe port="result" step="transcript"/>
      <p:pipe port="result" step="print"/>      
    </p:iteration-source>    
    <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
    <p:variable name="out" select="p:resolve-uri(replace($filename, $_xmlroot, 'converted/'), $_target)"/>
    
<!--    <cx:message>
			<p:with-option name="message" select="concat($filename, ' → ', $out)"></p:with-option>
		</cx:message>
-->		
    <p:load>
      <p:with-option name="href" select="$filename"/>
    </p:load>
    
    <p:xslt name="convert">      
      <p:input port="parameters"><p:empty/></p:input>
      <p:input port="stylesheet"><p:document href="update-tei-sources.xsl"/></p:input>
    </p:xslt>
    
    <p:xslt>   
      <p:input port="parameters"><p:empty/></p:input>
      <p:input port="stylesheet"><p:document href="xml-source-issues.xsl"/></p:input>
      <p:with-param name="filename" select="$filename"/>      
    </p:xslt>

    <p:xslt cx:after="save-metadata">
      <p:input port="stylesheet"><p:document href="header.xsl"/></p:input>      
      <p:with-option name="output-base-uri" select="$out"/>
      <p:with-param name="selected-md" select="p:resolve-uri('selected-metadata.xml', $_target)"/>      
      <p:with-param name="xmlroot" select="$_xmlroot"/>
      <p:with-param name="uri" select="replace($filename, $_xmlroot, 'faust://xml')"/>
    </p:xslt>
    
    <p:xslt>
      <p:input port="stylesheet"><p:document href="changenote.xsl"/></p:input>
      <p:with-param name="changenote" select="'Zu neuem Schema auf Basis von TEI P5 3.4.0 konvertiert'"/>
      <p:with-param name="changenote-who" select="'thvitt'"/>
      <p:with-param name="changenote-type" select="'automatic'"/>      
    </p:xslt>
    
    <p:store>
      <p:with-option name="href" select="$out"/>
    </p:store>
    
  </p:for-each>
  
</p:declare-step>
