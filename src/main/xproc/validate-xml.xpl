<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
	xmlns:l="http://xproc.org/library" type="f:list-transcripts" name="main" version="1.0">
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result" primary="true" sequence="true"><p:empty/></p:output>
	<p:serialization port="result" indent="true"/>
	
	<p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

	<p:variable name="errors-xml" select="resolve-uri('../../../target/validation-errors.xml')"></p:variable>

	<l:recursive-directory-list>
		<p:with-option name="path" select="'file:/home/tv/git/faust-schema/data/xml/transcript'"/>
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
						<p:document href="../../../target/schema/faust-tei.rng"/>
					</p:input>			
				</p:validate-with-relax-ng>

				<p:validate-with-schematron name="schematron">
					<p:input port="schema"><p:document href="../../../target/schema/faust-tei.sch"/></p:input>
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
					<p:input port="stylesheet"><p:inline>
						<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
							
							<xsl:template match="c:error" >
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
				
				
				<cx:message>
					<p:with-option name="message" select="concat('VALIDATION ERROR:', $filename, ':', string-join(distinct-values(//c:message), '; '))"/>
				</cx:message>		
				<p:wrap wrapper="f:validation-error" match="/"/>
			</p:catch>
		</p:try>
		<p:add-attribute attribute-name="filename" match="/*">
			<p:with-option name="attribute-value" select="$filename"/>
		</p:add-attribute>				
	</p:for-each>
	
	<p:wrap-sequence wrapper="validation-errors" name="wrap-errors"/>
	
	<cx:message>
		<p:with-option name="message" select="concat('Saving errors to ', $errors-xml)"/>
	</cx:message>
	
	<p:store name="store-errors" indent="true">
		<p:with-option name="href" select="$errors-xml"/>
	</p:store>
	
	<cx:message message="Saved errors.">
		<p:input port="source"><p:pipe port="result" step="store-errors"/></p:input>
	</cx:message>
		
	<p:sink/>
	
</p:declare-step>