<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:template name="start">
		<xsl:variable name="summary-lines">
			<xsl:for-each select="collection()">
				<xsl:choose>
					<xsl:when test="//title[@data-report-name]">
						<tr>
							<td><a href="{//title/@data-report-name}.html"><xsl:value-of select="//title"/></a></td>
							<td class="m"><xsl:value-of select="id('main-schema-error-count')"/></td>
							<td class="s"><xsl:value-of select="id('schematron-error-count')"/></td>
							<td class="v"><xsl:value-of select="id('valid-document-count')"/></td>
							<td><xsl:value-of select="id('timestamp')"/></td>
						</tr>													
					</xsl:when>
					<xsl:otherwise>
						<xsl:message select="concat('Skipping ', //title)"/>													
					</xsl:otherwise>
				</xsl:choose>							
			</xsl:for-each>
		</xsl:variable>
		<html>
			<head>
				<title>Validation Reports</title>
				<style>
					.m { text-align: right; background: #f88; }
					.v { text-align: right; background: #8f8; }
					.s { text-align: right; background: #ff8; }
				</style>								
			</head>
			<body>
				<h1>Validation Reports</h1>
				<table>
					<tbody>
						<xsl:message select="concat(count(collection()), ' reports ...')"/>
						<xsl:copy-of select="$summary-lines"/>						
					</tbody>
					<tfoot>
						<tr style="border-top: 1px solid black; font-weight: bold;">
							<td>Total</td>
							<td class="m"><xsl:value-of select="sum($summary-lines//td[@class='m'])"/></td>
							<td class="s"><xsl:value-of select="sum($summary-lines//td[@class='s'])"/></td>
							<td class="v"><xsl:value-of select="sum($summary-lines//td[@class='v'])"/></td>							
						</tr>
					</tfoot>
				</table>
			</body>							
		</html>
	</xsl:template>


</xsl:stylesheet>