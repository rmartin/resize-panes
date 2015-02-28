path = require 'path'
shell = require 'shell'
{BufferedProcess, CompositeDisposable} = require 'atom'
{Emitter, CompositeDisposable} = require 'event-kit'
{$, View} = require 'atom-space-pen-views'

toggleConfig = (keyPath) ->
  atom.config.set(keyPath, not atom.config.get(keyPath))


module.exports =
class ResizePaneView extends View
  panel: null
  treeViewWidth = 0
  editorPaneWidth = 0
  editorPaneOriginX = 0
  parent = null
  container = null

  @content: ->
    @div class: 'resize-pane-handle'

  initialize: (pane) ->
    @emitter = new Emitter
    @pane = pane
    @handleEvents()

  destroy: ->
    this.off('mousedown')
    this.remove()
    @emitter.emit 'did-destroy'
    @emitter.dispose()

  handleEvents: ->
    $(this).on('mousedown', (e) => @resizeStarted(e));

  resizeStarted: ({pageX, which}) =>
    treeViewWidth = $('.tree-view-scroller').outerWidth()
    editorPaneWidth = $(@pane).width()
    editorPaneOriginX = pageX
    $(document).on('mousemove', @resizePaneView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizePaneView)
    $(document).off('mouseup', @resizeStopped)

  resizePaneView: ({pageX, which}) =>
    return @resizeStopped() unless which is 1
    flexResizeWidth = (editorPaneWidth + (pageX - editorPaneOriginX)).toString()
    $(@pane).css('flex', '0 1 ' + flexResizeWidth + 'px')

  setParent: (parent) =>
    @parent = parent

  getParent: =>
    @parent

  setContainer: (container) =>
    @container = container

  getContainer: =>
    @container

  getPanes: ->
    []

  getItems: ->
    []

  onDidDestroy: (fn) ->
    @emitter.on 'did-destroy', fn
