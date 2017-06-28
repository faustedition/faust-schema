<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
	xmlns:l="http://xproc.org/library" type="f:validate-xmls" name="main" version="1.0">
	
	<p:option name="target" select="'../../../target/'"/>
	<p:option name="_target" select="resolve-uri($target)"/>
	<p:option name="xmlroot" select="'../../../data/xml/transcript'"></p:option>
	<p:option name="_xmlroot" select="resolve-uri($xmlroot)"/>
	<p:option name="rng" select="resolve-uri('schema/faust-tei.rng', $_target)"/>
	<p:option name="schematron" select="resolve-uri('schema/faust-tei.sch', $_target)"/>
	<p:option name="report-name" select="'faust-tei'"/>
	<p:option name="report-title" select="concat('Validation Errors ', $report-name)"/>
	<p:option name="linkroot"/>
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result" primary="true" sequence="true"><p:empty/></p:output>
	<p:serialization port="result" indent="true"/>
	
	<p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

	<p:variable name="errors-xml" select="resolve-uri(concat('report/', $report-name, '.xml'), $_target)"/>
	<p:variable name="report" select="resolve-uri(concat('report/', $report-name, '.html'), $_target)"/>
	
	<cx:message>
		<p:with-option name="message" select="concat(
			'&#10;target=', $target, '; resolved to ', $_target,
			'&#10;xmlroot=', $xmlroot, '; resolved to ', $_xmlroot,
			'&#10;rng=', $rng,
			'&#10;schematron=', $schematron,
			'&#10;report=', $report			
			)"></p:with-option>
	</cx:message>
	
	<p:load name="load-rng">
		<p:with-option name="href" select="$rng"/>
	</p:load>
	
	<p:load name="load-schematron">
		<p:with-option name="href" select="$schematron"/>
	</p:load>

	<l:recursive-directory-list>
		<p:with-option name="path" select="$_xmlroot"/>
	</l:recursive-directory-list>
	
	
	<p:for-each>
		<p:iteration-source select="//c:file"/>
		<p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
		
<!--		<cx:message>
			<p:with-option name="message" select="concat('Validating ', $filename)"></p:with-option>
		</cx:message>
-->		
		<p:load>
			<p:with-option name="href" select="$filename"/>
		</p:load>
		
		<p:try>
			<p:group>
				<p:validate-with-relax-ng assert-valid="true">
					<p:input port="schema">
						<p:pipe port="result" step="load-rng"/>
					</p:input>			
				</p:validate-with-relax-ng>

				<p:validate-with-schematron name="schematron" assert-valid="false">
					<p:input port="schema"><p:pipe port="result" step="load-schematron"/></p:input>
				</p:validate-with-schematron>
				
				<!-- We don't need the original XML -> work with report -->
				<p:identity>
					<p:input port="source"><p:pipe port="report" step="schematron"/></p:input>					
				</p:identity>
				
				<p:choose>
					<p:when test="//svrl:failed-assert">
						<p:wrap wrapper="f:validation-error" match="/"/>
					</p:when>
					<p:otherwise>
						<p:identity><p:input port="source"><p:inline><f:valid-document/></p:inline></p:input></p:identity>
					</p:otherwise>
				</p:choose>


			</p:group>
			
			<p:catch name="validate-catch">
				
				<!-- Work on the actual error document -->
				<p:identity>
					<p:input port="source"><p:pipe port="error" step="validate-catch"/></p:input>
				</p:identity>
				
								
				<!-- Markup the (plain-text) jing error message  -->
				<p:xslt>
					<p:with-param name="filename" select="$filename"/>
					<p:input port="stylesheet"><p:inline>
						<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
							
							<xsl:param name="filename"/>
							
							<xsl:template match="/">
								<xsl:variable name="all-errors">
									<xsl:apply-templates select="//c:error"/>
								</xsl:variable>
								
								<f:validation-error filename="{$filename}">
									<xsl:sequence select="$all-errors//c:error[@systemId = $filename]"/>
								</f:validation-error>
							</xsl:template>
														
							<xsl:template match="c:error">
								<xsl:copy>
									<xsl:copy-of select="@*"/>
									<xsl:analyze-string select="." regex="[^;]+; systemId: ([^;]+); lineNumber: \d+; columnNumber: \d+; ([^;]+); (.*)">
										<xsl:matching-substring>
											<xsl:attribute name="systemId" select="regex-group(1)"/>
											<c:message><xsl:value-of select="regex-group(2)"/></c:message>
											<c:resolution><xsl:value-of select="regex-group(3)"/></c:resolution>					
										</xsl:matching-substring>
										<xsl:non-matching-substring>
											<xsl:value-of select="."/>
										</xsl:non-matching-substring>
									</xsl:analyze-string>
								</xsl:copy>
							</xsl:template>
							
							<xsl:template match="node()|@*">
								<xsl:copy>
									<xsl:apply-templates mode="#current" select="@*, node()"/>
								</xsl:copy>
							</xsl:template>							
						
						</xsl:stylesheet>
					</p:inline></p:input>
				</p:xslt>
				
				
<!--				<cx:message>
					<p:with-option name="message" select="concat('VALIDATION ERROR:', $filename, ':', string-join(distinct-values(//c:message), '; '))"/>
				</cx:message>		
-->				<p:wrap wrapper="f:validation-error" match="/"/>
			</p:catch>
		</p:try>
		<p:add-attribute attribute-name="filename" match="/*">
			<p:with-option name="attribute-value" select="$filename"/>
		</p:add-attribute>				
	</p:for-each>
	
	<p:wrap-sequence wrapper="validation-errors" name="wrap-errors-0"/>
	
	<!-- drag ns decl up so serialization gets MUCH smaller -->
	<p:xslt name="wrap-errors">
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
					<xsl:template match="/*">
						<xsl:copy>
							<xsl:namespace name="f">http://www.faustedition.net/ns</xsl:namespace>
							<xsl:namespace name="c">http://www.w3.org/ns/xproc-step</xsl:namespace>
							<xsl:namespace name="err">http://www.w3.org/ns/xproc-error</xsl:namespace>
							<xsl:namespace name="cx">http://xmlcalabash.com/ns/extensions</xsl:namespace>
							<xsl:namespace name="pxf">http://exproc.org/proposed/steps/file</xsl:namespace>
							<xsl:namespace name="svrl">http://purl.oclc.org/dsdl/svrl</xsl:namespace>
							<xsl:namespace name="l">http://xproc.org/library</xsl:namespace>							
							<xsl:copy-of select="@*, node()"/>
						</xsl:copy>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>		
	</p:xslt>
	
	<cx:message>
		<p:with-option name="message" select="concat('Saving errors to ', $errors-xml)"/>
	</cx:message>
	
	<p:store name="store-errors" indent="true">
		<p:with-option name="href" select="$errors-xml"/>
	</p:store>
	
	<p:in-scope-names name="in-scope-names"/>
	
	<p:xslt>
		<p:input port="source"><p:pipe port="result" step="wrap-errors"/></p:input>
		<p:input port="stylesheet"><p:document href="validation-report.xsl"/></p:input>
		<p:input port="parameters"><p:pipe port="result" step="in-scope-names"/></p:input>
	</p:xslt>
	
	<cx:message>
		<p:with-option name="message" select="concat('Storing report to ', $report)"/>
	</cx:message>
	<p:store method="xhtml" indent="true">
		<p:with-option name="href" select="$report"/>
	</p:store>
		
	
	
</p:declare-step>