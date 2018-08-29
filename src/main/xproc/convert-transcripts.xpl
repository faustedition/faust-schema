<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:l="http://xproc.org/library" type="f:convert" name="main" version="1.0">
  
  <p:option name="target" select="'../../../target/'"/>
  <p:option name="_target" select="resolve-uri($target)"/>
  <p:option name="xmlroot" select="'../../../data/xml/transcript'"></p:option>
  <p:option name="_xmlroot" select="resolve-uri($xmlroot)"/>
  
  <p:input port="source"><p:empty/></p:input>
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result" primary="true" sequence="true"><p:empty/></p:output>
  <p:serialization port="result" indent="true"/>
  
  <p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <l:recursive-directory-list>
    <p:with-option name="path" select="$_xmlroot"/>
    <!--<p:with-option name="exclude-filter" select="$exclude-filter"/>-->
  </l:recursive-directory-list>
  
  <p:for-each>
    <p:iteration-source select="//c:file"/>
    <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
    <p:variable name="out" select="p:resolve-uri(replace($filename, $_xmlroot, 'converted'), $_target)"/>
    
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
    
    <p:store>
      <p:with-option name="href" select="$out"/>
    </p:store>
    
  </p:for-each>
  
</p:declare-step>