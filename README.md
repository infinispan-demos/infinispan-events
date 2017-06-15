# Infinispan Events

This is a fork of the [Elm Events](http://elm-events.org) website to promote 
upcoming Infinispan and JBoss Data Grid conference talks and meetups.

The architecture of this website is formed of 3-tiers: front-end based on Elm,
middleware based on Node.js/Express.js, and a backend using Infinispan.

## Requirements

* [Infinispan Server 9 or higher](http://infinispan.org/download/)
* Node.js 0.10. It is recommended that [NVM](https://github.com/creationix/nvm) 
is used to manage multiple Node.js versions.

## Running

1. Start Infinispan Server executing: `./bin/domain.sh`. 
Executing this starts up a domain formed of 2 nodes. If you want to add more 
nodes, modify `./domain/configuration/host.xml` file to add more server 
instances.

2. Adjust location of `infinispan` Node.js client dependency in 
`event-manager/package.json` file.

3. Execute `npm install` from root of `event-manager` folder.

4. Start the Node.js based middleware by changing directory to `event-manager`
and calling `node events.js`.

5. Start the Elm front-end by executing `npm start` from the root of this repo.

6. Go to http://localhost:8080.

## Live Events

Here's a list of conferences and user groups where this demo has been presented. 

* 28th June 2016 - Dev Nation ([slides](https://speakerdeck.com/galderz/building-reactive-applications-with-node-dot-js-data-grid) | [video](https://www.youtube.com/watch?v=ebUbzrpCuTA))
* 3rd November 2016 - Devoxx Morocco ([slides](https://speakerdeck.com/galderz/learn-how-to-build-functional-reactive-applications-with-elm-node-dot-js-and-infinispan-1) | video N/A)
* 19th May 2017 - J On The Beach ([slides](https://speakerdeck.com/galderz/learn-how-to-build-functional-reactive-applications-with-elm-node-dot-js-and-infinispan-2) | [video](https://www.youtube.com/watch?v=77uQLEdUzs8))
