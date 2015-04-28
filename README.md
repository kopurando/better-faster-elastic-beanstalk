better-faster-elastic-beanstalk
===============================

Collection of hooks for AWS Elastic Beanstalk node.js containers designed to dramatically increase deployment speeds, avoid unnecessary rebuilding of node_modules, install any version of node.js, install global NPM modules and more.

__NOTE__: this respo is way ahead of the StackOverflow thread you (most likely) came from, and heavily customised for my own use-case. It still works as a charm though and saves a lot of time on each deployment. So feel free to look around, be inspired and find solutions for your problems in my code, but it is essential to fork this repo and  adapt it for your own needs.

##todo
- remove (rename) and rebuild node_modules in case NodeJS or npm version gets changed 
