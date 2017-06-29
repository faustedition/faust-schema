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
	
	<f:validate-xmls report-name="metadata" report-title="Metadata">
		<p:with-option name="target" select="$_target"/>
		<p:with-option name="xmlroot" select="resolve-uri('document', $_xml)"/>
		<p:with-option name="xsd" select="resolve-uri('../src/main/xsd/metadata.xsd', $_target)"/> <!-- TODO -->
	</f:validate-xmls>

	<f:validate-xmls report-name="faust-tei" report-title="Transcripts (faust-tei)">
		<p:with-option name="target" select="$_target"/>
		<p:with-option name="xmlroot" select="p:resolve-uri('transcript', $_xml)"/>
		<p:with-option name="rng" select="resolve-uri('schema/faust-tei.rng', $_target)"/>
		<p:with-option name="schematron" select="resolve-uri('schema/faust-tei.sch', $_target)"/>
	</f:validate-xmls>
	
	<f:validate-xmls report-name="printed_editions" report-title="Printed Editions (printed_editions)">
		<p:with-option name="target" select="$_target"/>
		<p:with-option name="xmlroot" select="concat($xml, 'print/')"/>
		<p:with-option name="rng" select="resolve-uri('schema/printed_editions.rng', $_target)"/>
		<p:with-option name="schematron" select="resolve-uri('schema/printed_editions.sch', $_target)"/>
	</f:validate-xmls>

	<f:validate-xmls report-name="printed_editions_neu" report-title="Printed Editions Neu (printed_editions_neu)">
		<p:with-option name="target" select="$_target"/>
		<p:with-option name="xmlroot" select="concat($xml, 'print/')"/>
		<p:with-option name="rng" select="resolve-uri('schema/printed_editions_neu.rng', $_target)"/>
		<p:with-option name="schematron" select="resolve-uri('schema/printed_editions_neu.sch', $_target)"/>
	</f:validate-xmls>
		
	
	<p:sink/>

</p:declare-step>