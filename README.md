## Faustedition Schema Files

Schema files and guidelines for the [Faustedition](http://www.faustedition.net/).

## What is where

* `src/main/odd`: ODD sources for the schema files
* `src/main/xsd`: XML Schema files for formats that are not based on TEI
* `src/main/xml`: Examples and documentation
* `src/main/xproc`: Transformation scripts
* `attic`: Obsolete generated stuff

## Usage

### Schema generation

`mvn package` will generate the Relax NG and Schematron versions of all files
as well as HTML documentation to the `target/schema` directory.

### Validation

`mvn verify` will validate the XML files in `data` against their appropriate
schemas and generate summary reports, organized by error type. Note that
validation will _not_ take the schema association from `xsi:schemaLocation` or
`<?xml-model?>` into account but instead validate using the association in
`validate-all.xpl`.

### Deployment

`mvn deploy` will deploy the schema files to the appropriate schema directory.

## Script details

`generate-schemas.xpl` is a wrapper around the various TEI XSLTs to transform
ODDs. It will first expand the ODD and then generate RNG and Schematron files.

`validate-xml.xpl` takes a subdirectory, an exclude pattern and either an xsd or a relax ng schema + schematron rules and valides all files except the ones matching the exclude pattern against the schema files. It uses `validation-report.xsl` to generate a summary report that contains all errors, but grouped by error type and resolution instead of by file, since I consider this more useful for mass validation and systematic errors. Relax NG and XML Schema errors are given using line:column coordinates for each match, Schematron errors using XPaths pointing to the error.

The script also saves an XML file that contains the report organized by file.

`validate-all.xpl` runs `validate-xml.xpl` with appropriate settings for all the validation tasks for which we have schemas.
