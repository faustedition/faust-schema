<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:svrl="http://purl.oclc.org/dsdl/svrl"	
	exclude-result-prefixes="xs"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	version="2.0">
	
	<xsl:output method="xhtml"/>
	
	
	<xsl:template name="overall-stats">
		<table class="overall-stats">
			<tr style="background:#f88;">
				<td style="text-align:right;"><xsl:value-of select="count(//f:validation-error[.//c:error])"/></td>
				<td>documents are invalid by the Relax NG schema</td>
			</tr>
			<tr style="background:#ff8;"> 
				<td style="text-align:right;"><xsl:value-of select="count(//f:validation-error[.//svrl:failed-assert])"/></td>
				<td>documents pass Relax NG validation, but fail one or more Schematron assertions</td>
			</tr>
			<tr style="background:#8f8;">
				<td style="text-align:right;"><xsl:value-of select="count(//f:valid-document)"/></td>
				<td>documents are valid</td>
			</tr>
		</table>
	</xsl:template>
	
	<xsl:template name="rng-message-summary">
		<table>
			<tr>
				<th>Message</th>
				<th>Occurances</th>
				<th>Files</th>
			</tr>
			<xsl:for-each-group select="//c:error" group-by="c:message">
				<xsl:sort select="current-grouping-key()"/>
				<tr>
					<td><a href="#{generate-id(current-group()[1])}"><xsl:value-of select="current-grouping-key()"/></a></td>
					<td style="text-align:right;"><xsl:value-of select="count(current-group())"/></td>
					<td style="text-align:right;"><xsl:value-of select="count(current-group()/ancestor::f:validation-error)"/></td>
				</tr>
			</xsl:for-each-group>				
		</table>
	</xsl:template>
	
	

	<xsl:template match="/">
		<html>
			<head>
				<title>Validation Report</title>
				<style>
					dt { font-weight: bold; }
					.resolution { margin: 0; color: gray; }
					.locations { margin: 0; font-family: monospace}
				</style>
			</head>
			<body>
				<h2>Overall Summary</h2>
				<xsl:call-template name="overall-stats"/>
				
				<h2>Relax NG errors by message</h2>
				<xsl:call-template name="rng-message-summary"/>
				
				<h2>Individual Errors by message</h2>
				<xsl:call-template name="rng-by-message"/>
			</body>
		</html>		
	</xsl:template>
	
	<xsl:template name="rng-by-message">
		<dl>
			<xsl:for-each-group select="//c:error" group-by="c:message">
				<xsl:sort select="current-grouping-key()" stable="yes"/>
				<xsl:variable name="id" select="generate-id(current-group()[1])"/>
				<dt xml:id="{$id}" id="{$id}">
					<xsl:value-of select="current-grouping-key()"/>
				</dt>
				<dd>
					<p class="resolution"><xsl:value-of select="c:resolution"/></p>
					<ol>
						<xsl:for-each-group select="current-group()" group-by="ancestor::f:validation-error/@filename">
							<li>
								<a href="{current-grouping-key()}"><xsl:value-of select="current-grouping-key()"/></a>:
								<span class="locations">
									<xsl:value-of select="concat(count(current-group()), '×: ')"/>
									<xsl:for-each select="current-group()">
										<xsl:sort select="number(@line)"/>
										<xsl:sort select="number(@column)"/>
										<xsl:value-of select="concat(@line, ':', @column, ' ')"/>
									</xsl:for-each>									
								</span>
							</li>
						</xsl:for-each-group>
					</ol>
				</dd>
			</xsl:for-each-group>			
		</dl>
	</xsl:template>
	
	<xsl:template match="f:validation-error[c:errors]">
		<dt><a href="{@filename}"><xsl:value-of select="@filename"/></a></dt>
		<dd>
			<dl class="individual-errors">
				<xsl:for-each-group select=".//c:error" group-by="string-join((c:message, c:resolution), '|')">
					<xsl:sort select="number(current-group()[1]/@line)"/>
					<dt><xsl:value-of select="c:message"/></dt>
					<dd>						
						<p class="resolution"><xsl:value-of select="c:resolution"/></p>
						<p class="locations">
							<xsl:value-of select="concat(count(current-group()), '×: ')"/>
							<xsl:for-each select="current-group()">
								<xsl:sort select="number(@line)"/>
								<xsl:sort select="number(@column)"/>
								<xsl:value-of select="concat(@line, ':', @column, ' ')"/>
							</xsl:for-each>
						</p>		
					</dd>
				</xsl:for-each-group>
			</dl>
		</dd>
	</xsl:template>
	
</xsl:stylesheet>