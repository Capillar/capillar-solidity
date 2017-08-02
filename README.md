# Capillar.io
Logistics blockchain-based platform Capillar.io smart contracts public development.

For more information about Capillario project visit [capillar.io](http://capillar.io/)

## About
This repository contains files for testing ICO and platform contracts written in Solidity language.

Proof of concept folder contains initial test for implementing logistics functionality using smart contracts.

## Status
**Platform contacts**: proof of concept

**ICO contacts**: private testing, test coverage 100%

## Requirements
Tools used to compile contracts and run tests:
1. Truffle 3.4.6 ([learn more](http://truffleframework.com/docs/))
1. TestRPC v4.0.1 ([learn more](https://github.com/ethereumjs/testrpc))
1. NodeJS 6.0+ ([learn more](https://nodejs.org/en/))
1. Solidity 0.4.13 ([learn more](https://solidity.readthedocs.io/en/develop/))
1. ChaiJS 4.1.0. ([learn more](https://www.npmjs.com/package/chai))
1. Windows, Linux or Mac OS X

## Setup
1. Install NodeJS
1. Use npm to install TestRPC and Truffle
1. Pull repository files into local folder
1. Install chai locally: `npm install --save-dev chai`
1. Use `truffle compile` command in work folder to compile contracts
1. Start `testrpc` with default parameters
1. Use `truffle test` command to run tests

## Contract Rollout (ICO)
1. Test coverage 100% (see /tests in repository) [DONE]
1. Testing deployment in private testnet [IN PROGRESS]
1. Deployment in public testnet and public testing
1. Deployment in main Ethereum network and distributing tokens

## Known Issues
none

## Reporting an Issue
Feel free to open issues or request pull in test code
