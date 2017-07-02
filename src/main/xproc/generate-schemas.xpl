<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">
	<p:input port="source"><p:empty/></p:input>	
	<p:output port="result" sequence="true"><p:empty/></p:output>
	
	
	<p:option name="stylesheetsUrl" select="'http://www.tei-c.org/release/xml/tei/stylesheet/'"/>
	<p:option name="p5subsetUrl" select="'http://www.tei-c.org/Vault/P5/1.9.1/xml/tei/odd/p5subset.xml'"/>
	<p:option name="builddir" select="'target/'"></p:option>	
		
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	
	<p:variable name="target" select="p:resolve-uri($builddir)"></p:variable>
	
	<p:load name="load-odd2odd">
		<p:with-option name="href" select="p:resolve-uri('odds/odd2odd.xsl', $stylesheetsUrl)"/>			
	</p:load>
	
	<p:load name="load-odd2rng">
		<p:with-option name="href" select="p:resolve-uri('odds/odd2relax.xsl', $stylesheetsUrl)"/>			
	</p:load>
	
	<p:load name="load-odd2sch">
		<p:with-option name="href" select="p:resolve-uri('odds/extract-isosch.xsl', $stylesheetsUrl)"/>
	</p:load>
	
	<p:load name="load-odd2html">
		<p:with-option name="href" select="p:resolve-uri('odds/odd2html.xsl', $stylesheetsUrl)"/>
	</p:load>
	
	
	
	<p:directory-list>
		<p:with-option name="path" select="'../odd'"/>
	</p:directory-list>
	
	<p:for-each>
		<p:iteration-source select="//c:file"/>
		<p:variable name="name" select="data(/c:file/@name)"/>
		<p:variable name="odd" select="p:resolve-uri($name)"/>
		<p:variable name="expanded-odd" select="p:resolve-uri(concat('full-odd/', $name), $target)"/>
		<p:variable name="rng" select="p:resolve-uri(concat('schema/', replace($name, '\.xml$', '.rng')), $target)"/>
		<p:variable name="sch" select="p:resolve-uri(concat('schema/', replace($name, '\.xml$', '.sch')), $target)"/>
		<p:variable name="html" select="p:resolve-uri(concat('schema/', replace($name, '\.xml$', '.html')), $target)"/>
		
		<cx:message>
			<p:with-option name="message" select="concat('Converting ', $name, ' (', $odd, ') -> ', $expanded-odd, ' / ', $rng)"/>
		</cx:message>
		
		<p:load name="load-odd">
			<p:with-option name="href" select="$odd"/>			
		</p:load>

		<p:try>
			<p:group>
				<cx:message message=" - odd2odd"/>				
				<p:xslt name="odd2odd">
					<p:input port="stylesheet"><p:pipe port="result" step="load-odd2odd"/></p:input>
					<!--<p:with-param name="selectedSchema" select="'faust-tei'"/>-->
					<p:with-param name="verbose" select="'false'"/>
					<p:with-param name="stripped" select="'true'"/>
					<p:with-param name="defaultSource" select="$p5subsetUrl"/>
					<p:with-param name="TEIC" select="'true'"/>
					<p:with-param name="lang" select="'en'"/>
					<p:with-param name="doclang" select="'en'"/>
					<p:with-param name="useVersionFromTEI" select="'true'"/>
				</p:xslt>
				
				<cx:message message=" - odd2relax"/>
				
				<p:store indent="true">
					<p:with-option name="href" select="$expanded-odd"/>
				</p:store>
				
				<p:xslt name="odd2rng">
					<p:input port="source"><p:pipe port="result" step="odd2odd"/></p:input>
					<p:input port="stylesheet"><p:pipe port="result" step="load-odd2rng"/></p:input>
					<p:with-param name="verbose" select="'false'"/>
					<p:with-param name="TEIC" select="'true'"/>
					<p:with-param name="lang" select="'en'"/>
					<p:with-param name="doclang" select="'en'"/>
					<p:with-param name="parameterize" select="'false'"/>
					<p:with-param name="patternPrefix" select="'_tei'"/>			
				</p:xslt>
				
				<cx:message message=" - saving rng"/>
				
				<p:store indent="true">
					<p:with-option name="href" select="$rng"/>
				</p:store>
				
				<p:xslt name="extract-sch">
					<p:input port="stylesheet"><p:pipe port="result" step="load-odd2sch"/></p:input>
					<p:input port="source"><p:pipe port="result" step="odd2odd"/></p:input>
					<p:with-param name="lang" select="'en'"/>
				</p:xslt>
				
				<cx:message message=" - saving schematron"/>
				
				<p:store indent="true">
					<p:with-option name="href" select="$sch"/>
				</p:store>
				
				
				<p:xslt name="build-doc">
					<p:input port="stylesheet"><p:pipe port="result" step="load-odd2html"/></p:input>
					<p:input port="source"><p:pipe port="result" step="odd2odd"/></p:input>
					<p:with-param name="lang" select="'en'"/>					
				</p:xslt>
				
				<cx:message message=" - saving documentation"/>
				
				<p:store indent="false" method="xhtml" include-content-type="true">
					<p:with-option name="href" select="$html"/>
				</p:store>
				
				
				
			</p:group>
			<p:catch name="catch">
				<p:identity>
					<p:input port="source"><p:pipe port="error" step="catch"/></p:input>
				</p:identity>
				<cx:message>					
					<p:with-option name="message" select="concat('CONVERSION ERROR:', $name, ':', .)"/>
				</cx:message>
				<p:sink/>
			</p:catch>
		</p:try>
		
	</p:for-each>
	
	
	
</p:declare-step>
