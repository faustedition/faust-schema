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
            <xsl:attribute name="rend" select="if (@rend = 'erase') then 'erase' else 'strikethrough'"/>
            <xsl:apply-templates select="@* except @rend, node()"/>
        </mod>
    </xsl:template>
    
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
            <xsl:apply-templates select="@*, node()"/>
        </change>
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
    
</xsl:stylesheet>