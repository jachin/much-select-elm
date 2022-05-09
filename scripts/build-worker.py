#!/usr/bin/env python3

import os
from string import Template

os.system("npx elm make src/FilterWorker.elm --optimize --output src/gen/filter-worker-elm.js")

filter_worker_elm_js_file = open("src/gen/filter-worker-elm.js",'r')
filter_worker_elm_js_string = filter_worker_elm_js_file.read()

table = str.maketrans({
    "`": r"",
})

filter_worker_elm_js_string = filter_worker_elm_js_string.translate(table)
filter_worker_elm_js_string = filter_worker_elm_js_string.encode('unicode-escape').decode()

filter_worker_js_file = open("src/filter-worker.js",'r')
filter_worker_js_string = filter_worker_js_file.read()

filter_worker_template_js_file = open("src/much-select-template-template.js",'r')
filter_worker_template_js_string = filter_worker_template_js_file.read()

t = Template(filter_worker_template_js_string)
bundle_string = t.substitute(elm=filter_worker_elm_js_string, js=filter_worker_js_string)

filter_worker_bundle_js_file = open("src/gen/much-select-template.js",'w')
filter_worker_bundle_js_file.write(bundle_string)
