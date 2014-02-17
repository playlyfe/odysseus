Playlyfe Athena  [![Build Status](https://travis-ci.org/playlyfe/athena.png?branch=develop)](https://travis-ci.org/playlyfe/athena)
===

*A notification story compiler based on Playlyfe events*

---

Athena is a story spinner at heart, taking in the events in JSON format, and spinning out human readable sentences to be consumed by apps. Athena can output messages in both plaintext and HTML formats.

## Usage

Athena can be used as a node module, or as a *bower module* (todo)

#### Node

    Athena = require('athena');
    athena = new Athena(config);
    .
    .
    .

For getting proper messages in HTML format, you can supply a list of markup classes you want to assign different parts of the sentence. This markup class list will be in a key-value format like so:

    config.markup = {
      actor: "pl-actor",
      target: "pl-target",
      object: "pl-object",
      role_list: "pl-role-list",
      ...
      timestamp: "pl-ts"
    };

The meaning of the markup tags are listed below:

* actor: the actor in the event.
* player: the player (or rather, the target) in the event.
* object: the team/process in the event.
* role_list: the list of roles.
* diff_list: the list of changes.
* list_header: the title of the list.
* role: the role name.
* lane: the lane name.
* diff_add: the role **added** in a diff_list.
* diff_rem: the role **removed** in a diff_list.
* diff_change: the item in the diff_list which has both an addition **and** a removal.
* timestamp: the timestamp for the event.

---

## Authors

##### Kumar Harsh ([Github](https://github.com/kumarharsh))
##### Johny Jose  ([Github](https://github.com/atrniv))

## License

Copyright 2013 Playlyfe Technologies, LLP

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

---

![Playlyfe](http://www.playlyfe.com/favicon.ico)
