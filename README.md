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

## Presentations

This presentation was delivered in:

* Learn how to build Functional Reactive Applications with Elm, Node.js and Infinispan - Soft-Shake 2016
  * [Slides](https://speakerdeck.com/galderz/building-reactive-applications-with-node-dot-js-data-grid))
