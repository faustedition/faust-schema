#!/usr/bin/env python3
import sys
from collections import defaultdict
from html import escape
from urllib.parse import urlparse

from lxml import etree
from pathlib import Path

import logging
logger = logging.getLogger(name=__name__)

NS=dict(f="http://www.faustedition.net/ns",
        c="http://www.w3.org/ns/xproc-step",
        err="http://www.w3.org/ns/xproc-error",
        svrl="http://purl.oclc.org/dsdl/svrl")

PREFIX="""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Errors</title>
    <style>
        pre { margin-left: 2em; margin-bottom: 0; }
        .markers marked { background: #fdd; color: red; font-weight: bold; border: 2px solid #fdd; }
        .l { float: left; position: relative; left: -2em; width: 1.5em; text-align: right; color: gray; }
        .l:target { font-weight: bold; color: black; }
        div.errors { border: 1px solid red; border-top: none; background: #fdd;}
        div.errors p { margin-top: 0; margin-bottom: 0.5ex; }
        div.errors .message { font-weight: bold; }
        .pos { color: gray; font-family: monospace; }
    </style>
</head>
<body>
<pre>
"""
SUFFIX="""
</pre>
</div>
</body>
</html>
"""

def strip_common_prefix(source, reference, additional_components=0):
    source = Path(source).resolve()
    reference = Path(reference).resolve()
    for i, (source_part, reference_part) in enumerate(zip(source.parts, reference.parts)):
        if source_part != reference_part:
            break
    return Path(*source.parts[i+additional_components:])


def marker_string(columns):
    result = ""
    last_column = 0
    for column in columns:
        c = str(column)
        result += ' ' * (column - len(c) - last_column) + '<marked>' + c + '</marked>'
        last_column = column
    return result


def annotate_file(invalid_file, errors, out_path=None, strip_components=0):
    if out_path is None:
        out_path = Path()
    if not isinstance(out_path, Path):
        out_path = Path(urlparse(out_path).path)
    out_file = out_path / strip_common_prefix(invalid_file.with_suffix('.html'), out_path, strip_components)
    out_file.parent.mkdir(parents=True, exist_ok=True)

    logger.debug('Annotating %s to %s', invalid_file, out_file)

    with invalid_file.open(encoding='utf-8') as xml:
        with out_file.open('wt', encoding='utf-8') as out:
            out.write(PREFIX)
            for lineno, raw_line in enumerate(xml, start=1):
                line = escape(raw_line[:-1])
                out.write('<span id="l{0}" class="l">{0}</span>{1}\n'.format(lineno, line))
                if lineno in errors:
                    current_errors = errors[lineno]
                    markers = marker_string(error['column'] for error in current_errors)
                    out.write('<span class="l"> </span><span class="markers">{}</span></pre>\n<div class="errors">'.format(markers))
                    for error in current_errors:
                        out.write(('<p id="l{line}c{column}" class="message"><span class="pos">{line}:{column}</span> {message}</p>\n' +
                                   '<p class="resolution">{resolution}</p>\n').format_map(error))
                    out.write('</div><pre>')
            out.write(SUFFIX)


def parse_errors(fn):
    logger.debug('Parsing errors from %s ...', fn)
    if str(fn) == '-':
        et = etree.parse(sys.stdin)
    else:
        et = etree.parse(str(fn))
    for validation_error in et.xpath('//f:validation-error', namespaces=NS):
            url = validation_error.get('filename')
            invalid_file = Path(urlparse(url).path)
            errors = defaultdict(list)
            for error_xml in validation_error.xpath('.//c:error', namespaces=NS):
                error = dict(line=int(error_xml.get('line')),
                             column=int(error_xml.get('column')),
                             message=' '.join(error_xml.xpath('c:message/text()', namespaces=NS)),
                             resolution=' '.join(error_xml.xpath('c:resolution/text()', namespaces=NS)))
                errors[error['line']].append(error)
            yield invalid_file, errors


def _main():
    import argparse
    parser = argparse.ArgumentParser(description='Write annotated XML files for faust-schema validation output')
    parser.add_argument('report', help='XML report containing validation results')
    parser.add_argument('-o', '--output-dir', metavar='DIRECTORY', default='.')
    parser.add_argument('-s', '--strip-components', default=0, type=int,
                        help='number of additional path components to remove from source paths to form the output file name')
    options = parser.parse_args()
    logger.debug(options)

    for file, errors in parse_errors(Path(options.report)):
        annotate_file(file, errors, options.output_dir, options.strip_components)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    _main()
