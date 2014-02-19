{Odysseus} = require '../odysseus'
_ = require 'lodash'

describe 'The Odysseus Module', ->
  before (next) ->
    @odysseus = new Odysseus(global.config)
    @iso_date = global.iso_date
    @text_date = global.text_date
    @relative_date = global.relative_date
    next()

  describe 'initialization', ->
    it 'uses default markup if no markup map is passed', (next) ->
      arachne = new Odysseus()
      story = {
        event: 'join',
        actor: {
          id: 'snadella',
          alias: 'Satya'
        },
        team: {
          id: 'msft',
          name: 'Microsoft Inc.'
        },
        roles: {
          ceo: true,
          board_member: true
        },
        timestamp: @iso_date
      }
      expect(arachne.toHTML(story)).to.equal """
        <span class='od-actor'>Satya</span> joined the team <span class='od-object'>Microsoft Inc.</span> as <ul class='od-role-list'><li class='od-role'>ceo</li><li class='od-role'>board_member</li></ul>.<time class='od-ts' title='On #{@text_date}'>#{@relative_date}</time>
      """
      next()

  describe 'the compile method', ->
    it 'throws an error if an unsupported event is specified', (next) ->
      arachne = new Odysseus()
      expect(-> arachne.compile('h4x3d', 'text')).to.throw("The h4x3d event is not supported")
      next()

    it 'throws an error if the template type cannot be found', (next) ->
      arachne = new Odysseus()
      expect(-> arachne.compile('join', 'json')).to.throw("The json template for join event cannot be found")
      next()

    it 'returns the compiled template', (next) ->
      arachne = new Odysseus()
      expect(-> arachne.compile('join', 'text')).to.be.an.instanceof(Function)
      next()

  describe 'the toString method', ->
    it 'throws an error if no story is passed', (next) ->
      arachne = new Odysseus()
      expect(arachne.toString).to.throw("The story is not available")
      next()

  describe 'the toHTML method', ->
    it 'throws an error if no story is passed', (next) ->
      arachne = new Odysseus()
      expect(arachne.toHTML).to.throw("The story is not available")
      next()
