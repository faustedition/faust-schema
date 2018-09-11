<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"    
    xmlns:ge="http://www.tei-c.org/ns/geneticEditions"    
    xmlns:f="http://www.faustedition.net/ns"
    exclude-result-prefixes="xs ge"
    version="2.0">
    
    <xsl:param name="filename" select="document-uri(/)"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*, node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="TEI">
        <xsl:copy>
            <xsl:apply-templates select="@*, node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- https://github.com/faustedition/faust-gen-html/issues/175
        move stage at end of sp outside sp -->
    <xsl:template match="sp[stage[not(following-sibling::*)]]">
        <xsl:next-match/>
        <xsl:for-each select="stage[not(following-sibling::*)]">
            <xsl:copy>
                <xsl:apply-templates select="@*, node()"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="sp/stage[not(following-sibling::*)]"/>


    <!-- https://github.com/faustedition/faust-gen-html/issues/53
        remove xml:space="preserve" where redundant -->
    <xsl:template match="c[@xml:space='preserve']">
        <!--<xsl:message>c[xml:space='preserve'] in <xsl:value-of select="$filename"/>: <xsl:copy-of select=".."/></xsl:message>-->
        <xsl:next-match/>
    </xsl:template>
    <xsl:template match="@xml:space[parent::l|parent::line|parent::speaker|parent::note|parent::dateline|
                                      parent::p|parent::head|parent::stage|parent::sp|parent::mod[@type=('erase', 'strikethrough')]]"/>
    
    
    
    <!-- https://github.com/faustedition/faust-gen-html/issues/46
         Replace <name> by <hi> in XML sources 
    -->
    <xsl:template match="name">
        <xsl:element name="hi">
            <xsl:apply-templates select="@*, node()"/>
        </xsl:element>
    </xsl:template>    
    <xsl:template match="stage//hi/@status[. = 'name']"/>
    
    
    <xsl:template match="gap/@hand">
        <xsl:if test="data(.) != preceding::handShift[1]/@hand">
            <xsl:message>WARNING: gap/@hand=<xsl:value-of select="."/> != preceding handShift in <xsl:value-of select="document-uri(/)"/></xsl:message>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="sourceDoc//*[self::sic or self::corr][not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>