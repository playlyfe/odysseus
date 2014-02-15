moment = require 'moment'

global.chai = require 'chai'
global.should = chai.should()
global.expect = chai.expect
global.sinon = require 'sinon'
global.sinonChai = require 'sinon-chai'

date = new Date()
global.iso_date = @iso_date = date.toISOString()
global.text_date = @text_date = moment(date).format('llll')
global.relative_date = @relative_date = moment(date).fromNow()

global.config =
  markup:
    actor: "pl-actor"
    target: "pl-target"
    object: "pl-object"
    role_list: "pl-role-list"
    diff_list: "pl-diff-list"
    list_header: "pl-list-header"
    role: "pl-role"
    lane: "pl-lane"
    diff_add: "pl-diff-add"
    diff_rem: "pl-diff-rem"
    diff_change: "pl-diff-change"
    timestamp: "pl-ts"

chai.use sinonChai
