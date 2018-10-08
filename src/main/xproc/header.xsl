<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="faust-transcripts-uri" required="yes"/>
    <xsl:param name="transcripts" select="document($faust-transcripts-uri)"/>
    <xsl:param name="xmlroot"/>
    <xsl:param name="path"/>
    <xsl:variable name="transcript-el" select="$transcripts//f:textTranscript[@uri = concat('faust://xml/transcript/', $path)]"/>
    <xsl:variable name="sigil" select="$transcript-el/f:idno[@type='faustedition']/text()"/>
    <xsl:variable name="metadata-fn" select="resolve-uri($transcript-el/@document, $xmlroot)"/>
    <xsl:variable name="metadata" select="document($metadata-fn)"/>
    <xsl:variable name="archives" select="document(resolve-uri('archives.xml', $xmlroot))"/>

    <xsl:variable name="repo-sigils">
      <labels xmlns="http://www.faustedition.net/ns">
        <label type="gsa_1" kind="signature">GSA</label>
        <label type="gsa_2" kind="signature" >GSA</label>
        <label type="gsa_ident" kind="signature">GSA-Ident-Nr.</label>
        <label type="fdh_frankfurt" kind="signature">FRA</label>
        <label type="dla_marbach" kind="signature">MAR</label>
        <label type="sb_berlin" kind="signature">BER</label>
        <label type="ub_leipzig" kind="signature">LEI</label>
        <label type="ub_bonn" kind="signature">BON</label>
        <label type="veste_coburg" kind="signature">COB</label>
        <label type="gm_duesseldorf" kind="signature">DUE</label>
        <label type="sa_hannover" kind="signature">HAN</label>
        <label type="thlma_weimar" kind="signature">WEI</label>
        <label type="haab_weimar">WEI</label>
        <label type="bsb_muenchen" kind="signature">MUE</label>
        <label type="bb_cologny" kind="signature">COL</label>
        <label type="ub_basel" kind="signature">BAS</label>
        <label type="bj_krakow" kind="signature">KRA</label>
        <label type="agad_warszawa" kind="signature">WAR</label>
        <label type="bb_vicenza" kind="signature">VIC</label>
        <label type="bl_oxford" kind="signature">OXF</label>
        <label type="bl_london" kind="signature">LON</label>
        <label type="ul_edinburgh" kind="signature">EDI</label>
        <label type="ul_yale" kind="signature">YAL</label>
        <label type="tml_new_york" kind="signature">NY</label>
        <label type="ul_pennstate" kind="signature">PEN</label>
        <label type="mlm_paris">PAR</label>
      </labels>
    </xsl:variable>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="@*, node()"/>
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template match="fileDesc">
        <fileDesc>
            <titleStmt>
                <title type="main">Faust</title>
                <title type="sub">Historisch-kritische Edition</title>
                <author>Johann Wolfgang Goethe</author>
                <respStmt>
                    <resp>Herausgegeben von</resp>
                    <name>Anne Bohnenkamp</name>
                    <name>Silke Henke</name>
                    <name>Fotis Jannidis</name>
                    <orgName>Freies Deutsches Hochstift</orgName>
                    <orgName>Klassik Stiftung Weimar</orgName>
                    <orgName>Julius-Maximilians-Universität Würzburg</orgName>
                </respStmt>
                <respStmt>
                    <resp>Mitarbeit</resp>
                    <name>Gerrit Brüning</name>
                    <name>Katrin Henzel</name>
                    <name>Christoph Leijser</name>
                    <name>Gregor Middell</name>
                    <name>Dietmar Pravida</name>
                    <name>Thorsten Vitt</name>
                    <name>Moritz Wissenbach</name>
                </respStmt>
            </titleStmt>
            <publicationStmt>
                <publisher><!-- bleibt leer --></publisher>
                <idno type="faustedition"><xsl:value-of select="$sigil"/></idno>                
                <date><!-- generiert: date/@when --></date>
                <availability>
                    <licence target="https://creativecommons.org/licenses/by-nc-sa/4.0/"
                        >CreativeCommons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA
                        4.0)</licence>
                </availability>
            </publicationStmt>
            <sourceDesc>
                <msDesc><xsl:comment select="concat('/xml/', $transcript-el/@document)"/>
                    <msIdentifier>
                        <repository><xsl:value-of select="$archives//f:archive[@id=data($metadata//repository)]/f:displayName"/></repository>
                        <xsl:variable name="signatures" select="$metadata//f:idno[@type=$repo-sigils//f:idno/@type]"/>
                        <idno type="{$signatures[1]/@type}"><xsl:value-of select="$signatures[1]"/></idno>
                        <xsl:if test="count($signatures) > 1">
                            <altIdentifier>
                                <xsl:for-each select="subsequence($signatures, 2)">
                                    <idno type="@type"><xsl:value-of select="."/></idno>
                                </xsl:for-each>
                            </altIdentifier>
                        </xsl:if>
                    </msIdentifier>                    
                </msDesc>
            </sourceDesc>
        </fileDesc>        
    </xsl:template>
    
    
</xsl:stylesheet>