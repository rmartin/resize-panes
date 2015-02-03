path = require 'path'
shell = require 'shell'

{BufferedProcess, CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'

toggleConfig = (keyPath) ->
  atom.config.set(keyPath, not atom.config.get(keyPath))

module.exports =
class ResizePanel extends View
  panel: null

  @content: ->
    @div class: 'resize-panel-handle'

  initialize: (state) ->
    @handleEvents()
    @attach()

  attach: ->
    #TODO: attach item to the view for each of the tab panels

  attached: ->

  detached: ->

  serialize: ->

  deactivate: ->

  handleEvents: ->
    @on 'mousemove', 'document', (e) => @resizeMe(e)
    $(document).on('mousemove', (e) => @resizeMe(e));

  resizeMe: (e) =>
    if e.which ==1
      #TODO: Implement a better method to detect move and mousedown

  resizeStarted: =>
    $(document).on('mousemove', @resizeTreeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizeTreeView)
    $(document).off('mouseup', @resizeStopped)
