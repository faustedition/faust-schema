<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"    
    xmlns:ge="http://www.tei-c.org/ns/geneticEditions"    
    xmlns:f="http://www.faustedition.net/ns"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- This stylesheet transforms a single TEI file from the old ge sig based format to the new one, based on TEI 3.4.0 -->
    
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
            
    <xsl:template match="f:hspace">
        <space dim="horizontal">
            <xsl:apply-templates select="@*, node()"/>
        </space>
    </xsl:template>
    
    <xsl:template match="f:vspace">
        <space dim="vertical">
            <xsl:apply-templates select="@*, node()"/>
        </space>
    </xsl:template>
    
    <xsl:template match="f:st">
        <mod>
            <xsl:variable name="rend-tokens" select="tokenize(@rend, '\s+')" as="xs:string*"/>
            <xsl:attribute name="rend" select="string-join(($rend-tokens, if (not($rend-tokens = 'erase')) then 'strikethrough' else ()), ' ')"/>
            <xsl:apply-templates select="@* except @rend, node()"/>
        </mod>
    </xsl:template>
    
    <!--
    <xsl:template match="f:overw">
        <mod>
            <xsl:attribute name="rend" select="('overwrite', @rend)" separator=" "/>
            <xsl:apply-templates select="@* except @rend, node()"/>            
        </mod>
    </xsl:template>
    <xsl:template match="f:over">
        <seg>
            <xsl:attribute name="rend" select="'over', @rend" separator=" "/>
            <xsl:apply-templates select="@* except @rend, node()"/>
        </seg>
    </xsl:template>    
    <xsl:template match="f:under">
        <seg>
            <xsl:attribute name="rend" select="'under', @rend" separator=" "/>
            <xsl:apply-templates select="@* except @rend, node()"/>
        </seg>
    </xsl:template>
    -->
    
    <xsl:function name="f:attrib-without" as="attribute()?">
        <xsl:param name="attrib" as="attribute()?"/>
        <xsl:param name="without" as="xs:string"/>
        <xsl:variable name="tokens" select="tokenize($attrib, '\s+')"/>
        <xsl:variable name="clean-tokens" select="remove($tokens, index-of($tokens, $without))"/>
        <xsl:choose>
            <xsl:when test="empty($clean-tokens)"/>
            <xsl:otherwise>
                <xsl:attribute name="{name($attrib)}" select="string-join($clean-tokens, ' ')"/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:function>
    
    <!-- undo f:overw etc. -->
    <xsl:template match="mod[tokenize(@rend, '\s+') = 'overwrite']">
        <f:overw>
            <xsl:sequence select="f:attrib-without(@rend, 'overwrite')"/>
            <xsl:apply-templates select="@* except @rend, node()"/>
        </f:overw>
    </xsl:template>
    
    <xsl:template match="mod/seg[tokenize(@rend, '\s+') = 'over']">
        <f:over>
            <xsl:apply-templates select="f:attrib-without(@rend, 'over'), @* except @rend, node()"/>
        </f:over>
    </xsl:template>
    
    <xsl:template match="mod/seg[tokenize(@rend, '\s+') = 'under']">
        <f:under>
            <xsl:apply-templates select="f:attrib-without(@rend, 'under'), @* except @rend, node()"/>
        </f:under>
    </xsl:template>
    
    <!-- physical structure -->
    <xsl:template match="ge:document">
        <sourceDoc>
            <xsl:apply-templates select="@*, node()"/>
        </sourceDoc>
    </xsl:template>
    

    <xsl:template match="ge:surface">
        <surface>
            <xsl:apply-templates select="@*, node()"/>
        </surface>
    </xsl:template>
    
    <xsl:template match="ge:patch">
        <surface type="patch">
            <xsl:apply-templates select="@*, node()"/>
            <!-- ATTN: there are a bunch of attributes: binder=glue|pin|sewn, flipping (bool), height and width -->
            <!-- ATTN: surfaceGrp note? -->
        </surface>
    </xsl:template>
    
    <xsl:template match="ge:line">
        <line>
            <xsl:apply-templates select="@*, node()"/>
        </line>
    </xsl:template>
    
    <xsl:template match="alt/@targets">
        <xsl:attribute name="target" select="."/>
    </xsl:template>
    
    
    <xsl:template match="@ge:stage">
        <xsl:attribute name="change" select="."/>
    </xsl:template>
    
    <xsl:template match="ge:stageNotes">
        <listChange>
            <xsl:apply-templates select="@*, node()"/>
        </listChange>
    </xsl:template>
    
    <xsl:template match="ge:stageNote">
        <change>
            <xsl:apply-templates select="@*, node() except ge:stageNote"/>
            <xsl:if test="ge:stageNote">
                <listChange>
                    <xsl:apply-templates select="ge:stageNote"/>
                </listChange>
            </xsl:if>
        </change>
    </xsl:template>
   
   
    <xsl:template match="profileDesc[creation/ge:transposeGrp]">
        <xsl:copy>
            <xsl:apply-templates select="@*, text()[1], creation/ge:transposeGrp, node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="profileDesc/creation">
        <xsl:copy>
            <xsl:apply-templates select="@*, node() except ge:transposeGrp"/>
        </xsl:copy>
    </xsl:template>
       
    <xsl:template match="ge:transposeGrp">
        <listTranspose>
            <xsl:apply-templates select="@*, node()"/>
        </listTranspose>
    </xsl:template>
    
    <xsl:template match="ge:transpose">
        <transpose>
            <xsl:apply-templates select="@*, node()"/>
        </transpose>
    </xsl:template>


    <xsl:template match="ge:undo">
        <undo>
            <xsl:apply-templates select="@*, node()"/>
        </undo>
    </xsl:template>
    
    <xsl:template match="ge:rewrite">
        <retrace>
            <xsl:apply-templates select="@*, node()"/>
        </retrace>
    </xsl:template>

    <xsl:template match="ge:used">
        <metamark function="used">
            <xsl:apply-templates select="@* except @type, node()"/>
        </metamark>
    </xsl:template>
        
    <xsl:template match="processing-instruction('oxygen')|processing-instruction('xml-model')[not(preceding::processing-instruction('xml-model'))]">
        <xsl:processing-instruction name="xml-model">href="http://faustedition.net/schema/faust-tei.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>        
        <xsl:processing-instruction name="xml-model">href="http://faustedition.net/schema/faust-tei.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
    </xsl:template>
    <xsl:template match="processing-instruction('xml-model')[preceding::processing-instruction('xml-model')]"/>
    
</xsl:stylesheet>