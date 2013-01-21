---
layout: default
title: Development
---

In order to run Serenade.js locally and work on the code base, you will first
need to grab the codebase via git:

    git clone git://github.com/elabs/serenade.js.git
    cd serenade.js

Install dependencies via npm:

    npm install

Run the tests:

    npm test

Build Serenade.js into a single file:

    npm run-script build

You should now have the built project in `./extras`.

Run the example app:

    npm run-script examples
