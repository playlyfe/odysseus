Odysseus = require '../src/odysseus'
_ = require 'lodash'

describe 'The Odysseus Module', ->
  before (next) ->
    @odysseus = new Odysseus(global.config)
    @iso_date = global.iso_date
    @text_date = global.text_date
    @rel_date = global.rel_date
    next()

  describe 'initialization', ->
    it 'uses default markup if no markup map is passed', (next) ->
      odysseus = new Odysseus()
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
      expect(odysseus.toHTML(story)).to.equal """
        <div class='od-content'>\
          <span class='od-actor'>Satya</span> \
          joined the team \
          <span class='od-object'>Microsoft Inc.</span> \
          as \
          <ul class='od-role-list'>\
            <li><span class='od-role'>ceo</span></li>\
            <li><span class='od-role'>board_member</span></li>\
          </ul>.\
        </div>\
        <time class='od-ts' title='On #{@text_date}'>#{@rel_date}</time>
      """
      next()

  describe 'the compile method', ->
    it 'throws an error if an unsupported event is specified', (next) ->
      odysseus = new Odysseus()
      expect(-> odysseus.compile('h4x3d', 'text')).to.throw("The h4x3d event is not supported")
      next()

    it 'throws an error if the template type cannot be found', (next) ->
      odysseus = new Odysseus()
      expect(-> odysseus.compile('join', 'json')).to.throw("The json template for join event cannot be found")
      next()

    it 'returns the compiled template', (next) ->
      odysseus = new Odysseus()
      expect(-> odysseus.compile('join', 'text')).to.be.an.instanceof(Function)
      next()

  describe 'the toString method', ->
    before (next) ->
      @story = {
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
      next()

    it 'throws an error if no story is passed', (next) ->
      odysseus = new Odysseus()
      expect(odysseus.toString).to.throw("The story is not available")
      next()

    it 'builds the correct plain-text version of the story', (next) ->
      odysseus = new Odysseus()
      expect(odysseus.toString(@story)).to.equal """
        [#{@text_date}] - Satya joined the team 'Microsoft Inc.' \
        as ceo, board_member.
      """
      next()

  describe 'the getImage method', ->
    before (next) ->
      @story = {
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
      @externals = {base_url: '/assets/players'}
      next()

    it 'throws an error if no story is passed', (next) ->
      odysseus = new Odysseus()
      expect(odysseus.getImage).to.throw("The story is not available")
      next()

    it 'throws an error if no base_url is passed', (next) ->
      odysseus = new Odysseus()
      expect(=> odysseus.getImage(@story)).to.throw("The base source url is not specified")
      next()

    it 'shows an image if a valid story is passed', (next) ->
      odysseus = new Odysseus()
      expect(@odysseus.getImage(@story, @externals)).to.equal """
        <img src='/assets/players/snadella'>
      """
      next()

    it 'shows the dummy icon if experimenting with dummy players', (next) ->
      odysseus = new Odysseus()
      externals = _.extend {}, @externals, {env: 'debug'}
      expect(@odysseus.getImage(@story, externals)).to.equal """
        <i class='pl-icon-dummy'></i>
      """
      next()

  describe 'the toHTML method', ->
    before (next) ->
      @story = {
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
      @externals = {base_url: '/assets/players'}
      next()

    it 'throws an error if no story is passed', (next) ->
      odysseus = new Odysseus()
      expect(odysseus.toHTML).to.throw("The story is not available")
      next()

    it 'builds the correct HTML version of the story', (next) ->
      odysseus = new Odysseus()
      expect(odysseus.toHTML(@story)).to.equal """
        <div class='od-content'>\
          <span class='od-actor'>Satya</span> \
          joined the team \
          <span class='od-object'>Microsoft Inc.</span> \
          as \
          <ul class='od-role-list'>\
            <li><span class='od-role'>ceo</span></li>\
            <li><span class='od-role'>board_member</span></li>\
          </ul>.\
        </div>\
        <time class='od-ts' title='On #{@text_date}'>#{@rel_date}</time>
      """
      next()

    it 'shows no image if the image option is not passed or false', (next) ->
      odysseus = new Odysseus()
      expect(odysseus.toHTML(@story, @externals, {image: false})).to.equal """
        <div class='od-content'>\
          <span class='od-actor'>Satya</span> \
          joined the team \
          <span class='od-object'>Microsoft Inc.</span> \
          as \
          <ul class='od-role-list'>\
            <li><span class='od-role'>ceo</span></li>\
            <li><span class='od-role'>board_member</span></li>\
          </ul>.\
        </div>\
        <time class='od-ts' title='On #{@text_date}'>#{@rel_date}</time>
      """
      expect(odysseus.toHTML(@story, @externals)).to.equal """
        <div class='od-content'>\
          <span class='od-actor'>Satya</span> \
          joined the team \
          <span class='od-object'>Microsoft Inc.</span> \
          as \
          <ul class='od-role-list'>\
            <li><span class='od-role'>ceo</span></li>\
            <li><span class='od-role'>board_member</span></li>\
          </ul>.\
        </div>\
        <time class='od-ts' title='On #{@text_date}'>#{@rel_date}</time>
      """
      next()

    it 'shows an image if the image option is true', (next) ->
      odysseus = new Odysseus()
      expect(odysseus.toHTML(@story, @externals, {image: true})).to.equal """
        <div class='od-image'>\
          <img src='/assets/players/snadella'>\
        </div>\
        <div class='od-content'>\
          <span class='od-actor'>Satya</span> \
          joined the team \
          <span class='od-object'>Microsoft Inc.</span> \
          as \
          <ul class='od-role-list'>\
            <li><span class='od-role'>ceo</span></li>\
            <li><span class='od-role'>board_member</span></li>\
          </ul>.\
        </div>\
        <time class='od-ts' title='On #{@text_date}'>#{@rel_date}</time>
      """
      next()

