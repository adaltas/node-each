# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [2.4.1](https://github.com/adaltas/node-each/compare/v2.4.0...v2.4.1) (2023-09-08)

## [2.4.0](https://github.com/adaltas/node-each/compare/v2.3.0...v2.4.0) (2023-03-22)


### Features

* fluent option ([1bc3060](https://github.com/adaltas/node-each/commit/1bc3060e4eba111c3d0b508d4403c4c29e1c5ee0))

## [2.3.0](https://github.com/adaltas/node-each/compare/v2.2.1...v2.3.0) (2023-03-14)


### Features

* end resolve schedule items unless force ([9e1533c](https://github.com/adaltas/node-each/commit/9e1533cc745e43a536662dfecde2ef77ab9f8501))
* end with an error in relax mode ([cc781b4](https://github.com/adaltas/node-each/commit/cc781b411d18be26972254230ff95f12e3b0de6c))
* get fluent api ([90f3d3a](https://github.com/adaltas/node-each/commit/90f3d3a3144d00cdd4a532eaf26736d381353653))
* new api error function ([3743472](https://github.com/adaltas/node-each/commit/37434727699a4fa46c689463c6554d2514039388))
* pause and resume return a promise ([960fc91](https://github.com/adaltas/node-each/commit/960fc91a17a17c256bac9c0dac3d0111f8f1ac02))
* strict unhandled rejections mode ([6f8e542](https://github.com/adaltas/node-each/commit/6f8e5422efd6703096a85b19c1d09cba559d1b62))


### Bug Fixes

* move pinst to dev dependency ([3102fd0](https://github.com/adaltas/node-each/commit/3102fd014ffd0bc110189b25e6c4e074ea1bc611))

### [2.2.1](https://github.com/adaltas/node-each/compare/v2.2.0...v2.2.1) (2023-02-24)


### Bug Fixes

* preserve items structure when paused ([e12c018](https://github.com/adaltas/node-each/commit/e12c018b62ecef6ff001e28731d54ccb06f7ef31))

## [2.2.0](https://github.com/adaltas/node-each/compare/v2.1.0...v2.2.0) (2023-02-24)


### Features

* normalize get arguments length error ([3c8f377](https://github.com/adaltas/node-each/commit/3c8f37718793d8e47428b5e5308368614d9714ab))
* options get value ([04a748e](https://github.com/adaltas/node-each/commit/04a748e7bdd55f5b5f704a8a0a7d57a840a2af8b))
* rename set to options ([1afced9](https://github.com/adaltas/node-each/commit/1afced9821b2c354aad518e31b64bd5bea080ef7))

## [2.1.0](https://github.com/adaltas/node-each/compare/v2.0.1...v2.1.0) (2023-02-24)


### Features

* new end function ([440bd08](https://github.com/adaltas/node-each/commit/440bd0800f59b10c2a80cbfc88080955d3074862))
* new flatten option ([4b5ef37](https://github.com/adaltas/node-each/commit/4b5ef37bed9eebe29d639022f89784f246880ddf))
* resume and end wait scheduled iterations to complete ([a4c3d8f](https://github.com/adaltas/node-each/commit/a4c3d8f1a1350544bf0edfdf181f710f99e6926a))


### Bug Fixes

* correct and test invalid iniatilisation arguments ([96e732f](https://github.com/adaltas/node-each/commit/96e732ff007c74956184c39543ebf98fbb55de63))

### [2.0.1](https://github.com/adaltas/node-each/compare/v2.0.0...v2.0.1) (2023-02-22)


### Bug Fixes

* cjs module name ([dd3c6ed](https://github.com/adaltas/node-each/commit/dd3c6ed4abbba2ec908c75334b2867df88e0e870))

## [2.0.0](https://github.com/adaltas/node-each/compare/v1.2.2...v2.0.0) (2023-02-22)


### Features

* initial argument merging or unordered ([257be03](https://github.com/adaltas/node-each/commit/257be0304539b3178cb6f011994628f18c97bfa2))
* initial release for version 2 ([16ac09e](https://github.com/adaltas/node-each/commit/16ac09e053cfab42f5d2f2dd79f6ea5bfe628f89))


### Bug Fixes

* prevent stack execution on error ([fd21f2f](https://github.com/adaltas/node-each/commit/fd21f2f919e595d2e87956c1662ecd280d0ac0a9))


## Version 1.2.2

* coffee: update lint rules
* src: use callback instead of next
* readme: rewrite error doc
* promise: improve detection
* sample: update api.promise

## Version 1.2.1

* readme: document promise

## Version 1.2.0

* handler: handle multiple errors
* package: latest dev dependencies
* package: ignore lock files
* source: remove unused module dependencies

## Version 1.1.1

* src: fix latest release with js lost in transpilation

## Version 1.1.0

* package: npm release script
* options: pass options into the main function

## Version 1.0.0

* readme: rewrite doc
* next: rename then to next
* promise: error and then can be called before
* package: use CoffeeScript 2
* travis: run against node 7 and 8
* files: remove API function
* promise: new API function
* package: simplify run commands
