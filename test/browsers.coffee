Browsers = require('../lib/browsers')

data =
  ie:
    prefix:     '-ms-'
    versions:   [3, 2, 1]
    popularity: [1, 0.4, 0.1]
  chrome:
    prefix:     '-webkit-'
    future:     [5, 4]
    versions:   [3, 2, 1]
    popularity: [1, 0.5, 0.1]
  firefox:
    prefix:     '-moz-'
    versions:   [1]
    popularity: [0]
    minor:      true
  opera:
    prefix:     '-o-'
    versions:   [15, 4, 3, 2]
    popularity: [0.3, 0.1, 0.1]
    minor:      true
  bb:
    prefix:     '-webkit-'
    versions:   [1]
    popularity: [0]
    minor:      true

describe 'Browsers', ->

  describe '.prefixes()', ->

    it 'returns prefixes by default data', ->
      Browsers.prefixes().should.eql ['-webkit-', '-moz-', '-ms-', '-o-']

  describe '.withPrefix()', ->

    it 'finds possible prefix', ->
      Browsers.withPrefix('1 -o-calc(1)').should.be.true
      Browsers.withPrefix('1 calc(1)').should.be.false

  describe 'parse()', ->

    it 'converts browsers to array', ->
      browsers = new Browsers(data, ['last 2 versions'])
      browsers.selected.should.eql ['ie 3', 'ie 2', 'chrome 3', 'chrome 2']

    it 'allows to select no browsers', ->
      browsers = new Browsers(data, [])
      browsers.selected.should.be.empty

    it 'raises an error on unknown requirement', ->
      ( ->
        new Browsers(data, ['unknown'])
      ).should.throw('Unknown browser requirement `unknown`')

    it 'selects by latest versions', ->
      browsers = new Browsers(data, ['last 1 version'])
      browsers.selected.should.eql ['ie 3', 'chrome 3']

    it 'selects by latest versions by browser', ->
      browsers = new Browsers(data, ['last 2 chrome versions'])
      browsers.selected.should.eql ['chrome 3', 'chrome 2']

    it 'selects by popularity', ->
      browsers = new Browsers(data, ['> 0.2%'])
      browsers.selected.should.eql ['ie 3', 'ie 2', 'chrome 3', 'chrome 2']

    it 'selects by older version', ->
      browsers = new Browsers(data, ['opera > 3'])
      browsers.selected.should.eql ['opera 15', 'opera 4']

    it 'selects by older version inclusive', ->
      browsers = new Browsers(data, ['opera >= 3'])
      browsers.selected.should.eql ['opera 15', 'opera 4', 'opera 3']

    it 'selects by newer version', ->
      browsers = new Browsers(data, ['opera < 4'])
      browsers.selected.should.eql ['opera 3', 'opera 2']

    it 'selects by newer version inclusive', ->
      browsers = new Browsers(data, ['opera <= 4'])
      browsers.selected.should.eql ['opera 4', 'opera 3', 'opera 2']

    it 'selects Firefox ESR', ->
      browsers = new Browsers(data, ['Firefox ESR'])
      browsers.selected.should.eql ['firefox 31']

    it 'follows explicit requirements', ->
      browsers = new Browsers(data, ['chrome 5', 'opera 4'])
      browsers.selected.should.eql ['chrome 5', 'opera 4']

    it 'selects unreleased versions', ->
      browsers = new Browsers(data, ['chrome 10', 'opera 1'])
      browsers.selected.should.eql ['chrome 5', 'opera 2']

    it 'combines requirements', ->
      browsers = new Browsers(data, ['last 2 versions', '> 0.4%'])
      browsers.selected.should.eql ['ie 3', 'ie 2', 'chrome 3', 'chrome 2']

    it 'has aliases', ->
      ( new Browsers(data, ['fx >= 1']) ).selected.should.eql ['firefox 1']
      ( new Browsers(data, ['ff >= 1']) ).selected.should.eql ['firefox 1']

    it 'ignores case', ->
      ( new Browsers(data, ['Firefox 1']) ).selected.should.eql ['firefox 1']

  describe 'prefix()', ->

    it 'returns browser prefix', ->
      browsers = new Browsers(data, ['chrome 3'])
      browsers.prefix('chrome 3').should == '-webkit-'

    it 'returns webkit prefix for Opera 15', ->
      browsers = new Browsers(data, ['opera > 4'])
      browsers.prefix('opera 4').should  == '-o-'
      browsers.prefix('opera 15').should == '-webkit-'

  describe 'isSelected()', ->

    it 'return true for selected browsers', ->
      browsers = new Browsers(data, ['chrome 3', 'chrome 2'])
      browsers.isSelected('chrome 2').should.be.true
      browsers.isSelected('ie 2').should.be.false
