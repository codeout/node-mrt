# node-mrt

## Description

MRT archive downloader for NodeJS. It downloads from archive.routeviews.org and caches for your further actions.

## Installation

```zsh
npm install https://github.com/codeout/node-mrt.git
```

## Usage

```javascript
MRT = require('node-mrt')
mrt = new MRT('wide')

mrt.get(function(err) {
  console.log(err);
}, function(path) {
  console.log("Path: " + path);
});
```

## Configuration

This script uses environment variables below:

* ```MRT_CACHE_TIMEOUT``` - How long it keeps MRT file cache in seconds

## Copyright and License

Copyright (c) 2016 Shintaro Kojima. Code released under the [MIT license](LICENSE).


