FROM airstack/core:development

COPY command /package/json/json-utils/command
COPY test /package/json/json-utils/test

RUN set -e; \
  ln -sf /package/json/json-utils/command/core-* /command/; \
  sudo ln -sf /package/json/json-utils/command/json2env /command/json2env; \
  sudo ln -sf /package/json/json-utils/command/json-deep-merge /usr/local/bin/json-deep-merge
