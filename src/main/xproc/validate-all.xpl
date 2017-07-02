<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
	xmlns:l="http://xproc.org/library" type="f:validate-all" name="main" version="1.0">
	
	<p:option name="target" select="'../../../target/'"/>
	<p:option name="_target" select="resolve-uri($target)"/>
	<p:option name="xml" select="'../../../data/xml/'"></p:option>
	<p:option name="_xml" select="resolve-uri($xml)"/>
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result" primary="true" sequence="true"><p:empty/></p:output>
	<p:serialization port="result" indent="true"/>
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="validate-xml.xpl"/>
	
	<p:group name="validations">		
	
		<f:validate-xmls report-name="metadata" report-title="Metadata (Transcripts)">
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="resolve-uri('document', $_xml)"/>
			<p:with-option name="xsd" select="resolve-uri('schema/metadata.xsd', $_target)"/>
			<p:with-option name="exclude-filter" select="'print'"/>
			<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/document/'"/>
		</f:validate-xmls>
		
		<f:validate-xmls report-name="metadata_print" report-title="Metadata (Prints)">
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="resolve-uri('document/print', $_xml)"/>
			<p:with-option name="xsd" select="resolve-uri('schema/metadata_print.xsd', $_target)"/>
			<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/document/print/'"/>
		</f:validate-xmls>
		
		<f:validate-xmls report-name="macrogenesis" report-title="Macrogenesis Data">
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="resolve-uri('macrogenesis', $_xml)"/>
			<p:with-option name="xsd" select="resolve-uri('schema/macrogenesis.xsd', $_target)"/> <!-- TODO -->
			<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/macrogenesis/'"/>
		</f:validate-xmls>
				
		<f:validate-xmls report-name="faust-tei" report-title="Transcripts (faust-tei)">
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="p:resolve-uri('transcript', $_xml)"/>
			<p:with-option name="rng" select="resolve-uri('schema/faust-tei.rng', $_target)"/>
			<p:with-option name="schematron" select="resolve-uri('schema/faust-tei.sch', $_target)"/>
			<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/transcript/'"/>
		</f:validate-xmls>
	
		<f:validate-xmls report-name="printed_editions_neu" report-title="Printed Editions Neu (printed_editions_neu)">
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="concat($xml, 'print')"/>
			<p:with-option name="rng" select="resolve-uri('schema/printed_editions_neu.rng', $_target)"/>
			<p:with-option name="schematron" select="resolve-uri('schema/printed_editions_neu.sch', $_target)"/>
			<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/print/'"/>
		</f:validate-xmls>
			
	</p:group>
	
	<cx:message>
		<p:with-option name="message" select="concat('Loading reports from ', resolve-uri('report', $_target))"/>
	</cx:message>
	
	<p:directory-list include-filter=".*\.html$">
		<p:with-option name="path" select="resolve-uri('report', $_target)"/>
	</p:directory-list>
	
	<p:for-each name="load-reports">
		<p:iteration-source select="//c:file"/>
		<p:variable name="report-uri" select="resolve-uri(/c:file/@name, resolve-uri('report/', $_target))"/>
		<cx:message>
			<p:with-option name="message" select="concat('Loading report ', $report-uri)"/>
		</cx:message>
		<p:try>
			<p:group>
				<p:load>
					<p:with-option name="href" select="$report-uri"/>
				</p:load>				
			</p:group>
			<p:catch name="catch-load-report">
				<cx:message>
					<p:with-option name="message" select="concat('Failed to load ', $report-uri, ': ', .)"/>
					<p:input port="source"><p:pipe port="error" step="catch-load-report"/></p:input>
				</cx:message>
				<p:identity><p:input port="source"><p:empty/></p:input></p:identity>
			</p:catch>
		</p:try>
	</p:for-each>
	
	<p:xslt template-name="start" name="index-html">
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
					xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml">
					<xsl:template name="start">
						<html>
							<head>
								<title>Validation Reports</title>
								<style>
									.r { text-align: right; background: #f88; }
									.g { text-align: right; background: #8f8; }
									.y { text-align: right; background: #ff8; }
								</style>								
							</head>
							<body>
								<h1>Validation Reports</h1>
								<table>
									<tbody>
										<xsl:message select="concat(count(collection()), ' reports ...')"/>
										<xsl:for-each select="collection()">
											<xsl:choose>
												<xsl:when test="//title[@data-report-name]">
													<tr>
														<td><a href="{//title/@data-report-name}.html"><xsl:value-of select="//title"/></a></td>
														<td class="r"><xsl:value-of select="id('main-schema-error-count')"/></td>
														<td class="y"><xsl:value-of select="id('schematron-error-count')"/></td>
														<td class="g"><xsl:value-of select="id('valid-document-count')"/></td>
														<td><xsl:value-of select="id('timestamp')"/></td>
													</tr>													
												</xsl:when>
												<xsl:otherwise>
													<xsl:message select="concat('Skipping ', //title)"/>													
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</tbody>									
								</table>
							</body>							
						</html>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
	</p:xslt>
	
	<p:store method="xhtml" indent="true">
		<p:with-option name="href" select="resolve-uri('report/index.html', $_target)"/>
	</p:store>


</p:declare-step>