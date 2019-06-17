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
				
		<f:validate-xmls report-name="metadata" report-title="Metadata (Transcripts)" linkroot='xml/document'>
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="resolve-uri('document', $_xml)"/>
			<p:with-option name="xsd" select="resolve-uri('schema/metadata.xsd', $_target)"/>
			<p:with-option name="exclude-filter" select="'print'"/>
			<!--<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/document/'"/>-->
		</f:validate-xmls>
		
		<f:validate-xmls report-name="metadata_print" report-title="Metadata (Prints)" linkroot='xml/document'>
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="resolve-uri('document/print', $_xml)"/>
			<p:with-option name="xsd" select="resolve-uri('schema/metadata_print.xsd', $_target)"/>
			<!--<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/document/print/'"/>-->
		</f:validate-xmls>
		
		<f:validate-xmls report-name="macrogenesis" report-title="Macrogenesis Data" linkroot='xml/macrogenesis'>
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="resolve-uri('macrogenesis', $_xml)"/>
			<p:with-option name="rnc" select="resolve-uri('macrogenesis/macrogenesis.rnc', $_xml)"/> 
			<!--<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/macrogenesis/'"/>-->
		</f:validate-xmls>
				
		<f:validate-xmls report-name="faust-tei" report-title="Converted Transcripts and Prints (faust-tei)" linkroot='' exclude-filter="test">
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="p:resolve-uri('converted', $_target)"/>
			<p:with-option name="rng" select="resolve-uri('schema/faust-tei.rng', $_target)"/>
			<p:with-option name="schematron" select="resolve-uri('schema/faust-tei.sch', $_target)"/>
			<!--<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/transcript/'"/>-->
		</f:validate-xmls>
	
<!--		<f:validate-xmls report-name="printed_editions_neu" report-title="Converted Prints (faust-tei)" linkroot='prints'>
			<p:with-option name="target" select="$_target"/>
			<p:with-option name="xmlroot" select="concat($xml, 'print')"/>
			<p:with-option name="rng" select="resolve-uri('schema/printed_editions_neu.rng', $_target)"/>
			<p:with-option name="schematron" select="resolve-uri('schema/printed_editions_neu.sch', $_target)"/>
			<!-\-<p:with-option name="linkroot" select="'https://faustedition.uni-wuerzburg.de/xml/print/'"/>-\->
		</f:validate-xmls>
-->			
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
			<p:document href="validation-summary.xsl"/>
		</p:input>
	</p:xslt>
	
	<p:store method="xhtml" indent="true">
		<p:with-option name="href" select="resolve-uri('report/index.html', $_target)"/>
	</p:store>
	
	<p:directory-list include-filter=".*\.xml$">
		<p:with-option name="path" select="resolve-uri('report', $_target)"/>
	</p:directory-list>
	<p:for-each>
		<p:iteration-source select="//c:file"/>
		<p:variable name="report-uri" select="resolve-uri(/c:file/@name, resolve-uri('report/', $_target))"/>
		<cx:message>
			<p:with-option name="message" select="concat('Annotating XMLs for ', $report-uri)"/>
		</cx:message>
		<p:try>
			<p:group>
				<p:exec command="src/main/tools/highlight-errors.py" source-is-xml="true" errors-is-xml="false" result-is-xml="false">
					<p:with-option name="args" select="string-join(('-s1', '-o', resolve-uri('report/', $_target), $report-uri), ' ')"/>
					<p:input port="source"><p:empty/></p:input>		
				</p:exec>				
			</p:group>
			<p:catch name="catch-ann-xml">
				<cx:message>
					<p:with-option name="message" select="concat('Failed to load ', $report-uri, ': ', .)"/>
					<p:input port="source"><p:pipe port="error" step="catch-ann-xml"/></p:input>
				</cx:message>
				<p:identity><p:input port="source"><p:empty/></p:input></p:identity>
			</p:catch>
		</p:try>
		
	</p:for-each>

	<p:sink/>

</p:declare-step>