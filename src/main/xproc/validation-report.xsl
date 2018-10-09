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
	
	<xsl:param name="report-title">Validation Errors</xsl:param>
	<xsl:param name="report-name"/>
	<xsl:param name="_xmlroot" select="static-base-uri()"/>
	<xsl:variable name="linkroot" select="/*/@linkroot"/>
	<xsl:param name="rng"/>
	<xsl:param name="schematron"/>
	<xsl:param name="xsd"/>
		
	
	
	<xsl:function name="f:linkxml" as="element()">
		<xsl:param name="uri"/>
		<xsl:variable name="relpath" 
			select="if (starts-with($uri, $_xmlroot))
						then substring($uri, string-length($_xmlroot) + 
								(if (ends-with('/', $_xmlroot)) then 1 else 2))
						else $uri"/>
		<xsl:variable name="link" select="replace(if ($linkroot != '') then string-join(($linkroot, $relpath), '/') else $relpath, '\.xml$', '.html')"/>
		<a href="{$link}"><xsl:value-of select="$relpath"/></a>
		
	</xsl:function>
	
	
	<xsl:template name="overall-stats">
		<xsl:variable name="validationErrors" select="count(//f:validation-error[.//c:error])"/>
		<xsl:variable name="schematronErrors" select="count(//f:validation-error[.//svrl:failed-assert])"/>
		<xsl:variable name="valid" select="count(//f:valid-document)"/>
		<table class="overall-stats">
			<tr class="error-bg">
				<td xml:id="main-schema-error-count" class="right">
					<xsl:value-of select="$validationErrors"/></td>
				<td><a href="#rng-summary">documents are invalid by the main schema</a></td>
			</tr>
			<tr class="warning-bg"> 
				<td xml:id="schematron-error-count" style="text-align:right;">
					<xsl:value-of select="$schematronErrors"/></td>
				<td><a href="#schematron">documents pass main schema validation, but fail one or more Schematron assertions</a></td>
			</tr>
			<tr class="ok-bg">
				<td xml:id="valid-document-count" class="right">
					<xsl:value-of select="$valid"/></td>
				<td>documents are valid</td>
			</tr>
		</table>
		<!--<xsl:message select="concat('Valid documents: ', $valid, ', invalid by main schema: ', $validationErrors, ', invalid by schematron: ', $schematronErrors)"/>-->
	</xsl:template>
	
	<xsl:template name="rng-message-summary">
		<table>
			<tr>
				<th>Message</th>
				<th>Occurances</th>
				<th>Files</th>
			</tr>
			<xsl:for-each-group select="//c:error" group-by="c:message">
				<xsl:sort select="count(current-group())" order="descending"/>
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
				<title data-report-name="{$report-name}"><xsl:value-of select="$report-title"/></title>
				<style>
					dt { font-weight: bold; }
					.right { text-align: right; }
					.error-bg { background: #f88; }
					.warning-bg { background: #ff8; }
					.ok-bg { background: #8f8; } 
					.resolution { margin: 0; color: gray; }
					.locations { margin: 0; font-family: monospace}
					small.xpath { color: gray; }
				</style>
			</head>
			<body>
				<h1><xsl:value-of select="$report-title"/></h1>
				<table>
					<tr><td>XML Root</td><td><xsl:value-of select="$_xmlroot"/></td></tr>
					<xsl:choose>
						<xsl:when test="$rng">
							<tr><td>Main schema (Relax NG)</td><td><xsl:value-of select="$rng"/></td></tr>							
						</xsl:when>
						<xsl:otherwise>
							<tr><td>Main schema (XML Schema)</td><td><xsl:value-of select="$xsd"/></td></tr>
						</xsl:otherwise>
					</xsl:choose>
					<tr><td>Schematron document</td><td><xsl:value-of select="$schematron"/></td></tr>
					<tr><td>Validation date</td><td xml:id="timestamp"><xsl:value-of select="current-dateTime()"/></td></tr>
				</table>
				
				<h2>Overall Summary</h2>
				<xsl:call-template name="overall-stats"/>
				
				<h2 id="rng-summary">Main schema errors by message</h2>
				<xsl:call-template name="rng-message-summary"/>
				
				<h2 id="rng-details">Individual schema errors by message</h2>
				<xsl:call-template name="rng-by-message"/>
				
				<h2 id="schematron">Individual Schematron errors by message</h2>
				<xsl:call-template name="schematron-details"/>
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
				<xsl:for-each-group select="current-group()" group-by="c:resolution">
					<dd>
						<p class="resolution"><xsl:value-of select="current-grouping-key()"/></p>
						<ol>
							<xsl:for-each-group select="current-group()" group-by="ancestor::f:validation-error/@filename">
								<li>
									<xsl:sequence select="f:linkxml(current-grouping-key())"/>:
									<xsl:variable name="href" select="f:linkxml(current-grouping-key())/@href"/>
									<!--<xsl:message select="concat('filename=', current-grouping-key(), 'href=', $href, ' xmlroot=', $_xmlroot, ' linkroot=', $linkroot)"/>-->
									<span class="locations">
										<xsl:value-of select="concat(count(current-group()), '×: ')"/>
										<xsl:for-each select="current-group()">
											<xsl:sort select="number(@line)"/>
											<xsl:sort select="number(@column)"/>
											<a href="{$href}#l{@line}">
												<xsl:value-of select="concat(@line, ':', @column, ' ')"/>
											</a>
											
										</xsl:for-each>									
									</span>
								</li>
							</xsl:for-each-group>
						</ol>
					</dd>
				</xsl:for-each-group>
			</xsl:for-each-group>
		</dl>
	</xsl:template>
	
	<xsl:template name="schematron-details">
		<dl>
			<xsl:for-each-group select="//svrl:failed-assert" group-by="normalize-space(svrl:text)">
				<dt><xsl:value-of select="current-grouping-key()"/></dt>
				<dd><ol>
					<xsl:for-each select="current-group()">
						<li>
							<xsl:sequence select="f:linkxml(ancestor::f:validation-error/@filename)"/><xsl:text>: </xsl:text>
							<xsl:value-of select="preceding-sibling::svrl:fired-rule[1]/@context"/><xsl:text> </xsl:text>
							<small class="xpath"><xsl:value-of select="
								replace(@location, &quot;\*:([a-zA-Z]+)\[namespace-uri\(\)='http://www.tei-c.org/ns/1.0'\]&quot;, 'tei:$1')"/></small>							
						</li>
					</xsl:for-each>					
				</ol></dd>
			</xsl:for-each-group>			
		</dl>
	</xsl:template>
	
	<xsl:template match="f:validation-error[c:errors]">
		<xsl:variable name="href" select="f:linkxml(@filename)/@href"/>
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
								<a href="{$href}#l{@line}">
									<xsl:value-of select="concat(@line, ':', @column, ' ')"/>
								</a>
							</xsl:for-each>
						</p>		
					</dd>
				</xsl:for-each-group>
			</dl>
		</dd>
	</xsl:template>
	
</xsl:stylesheet>