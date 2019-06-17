<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:fx="http://www.faustedition.net/ns/xproc"
  type="fx:load-data" name="load-data"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  <p:option name="href"/>
  <p:input port="source">
    <p:empty/>
  </p:input>
  <p:output port="result"/>
  
  <p:xslt name="prepare-request" template-name="create-request">
    <p:input port="source"><p:empty/></p:input>
    <p:with-param name="href" select="$href"/>
    <p:input port="stylesheet"><p:inline>
      <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
        <xsl:param name="href"/>
        <xsl:template name="create-request">
          <c:request method="GET" href="{$href}" override-content-type="text/plain"/>
        </xsl:template>
      </xsl:stylesheet>
    </p:inline></p:input>
  </p:xslt>
  
  <p:http-request name="do-request"/>
  
  <p:xslt name="extract-body">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
          <xsl:template match="/">
            <c:data>
              <xsl:copy-of select="//c:body/node()"/>
            </c:data>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>      
    </p:input>
    <p:input port="parameters"><p:empty/></p:input>
  </p:xslt>
  
</p:declare-step>