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
    score_activity: "pl-activity"
    score_table: "pl-score-table"
    score_table_header: "pl-score-header"
    score_table_body: "pl-score-body"
    score_metric: "pl-score-metric"
    score_delta_item: "pl-score-delta-item"
    score_delta_value: "pl-score-delta-value"
    achievement_table: "pl-achievement-table"
    timestamp: "pl-ts"

chai.use sinonChai
