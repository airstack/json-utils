# JSON Utils

Shell scripts for processing JSON and exporting JSON to ENV vars.


# Requirements

- sh or bash
- [jq json processor](http://stedolan.github.io/jq/)


# Testing

Tests are written in Lua using the [Telescope](https://github.com/norman/telescope)
test framework.

`make test` runs tests in an [airstack/core](https://github.com/airstack/core)
Docker image that already includes jq, luajit, and telescope.

```bash
# With Docker installed on the host...

make build && make test
```
