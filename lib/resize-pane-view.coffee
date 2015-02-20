path = require 'path'
shell = require 'shell'
{BufferedProcess, CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'


toggleConfig = (keyPath) ->
  atom.config.set(keyPath, not atom.config.get(keyPath))


module.exports =
class ResizePaneView extends View
  panel: null
  treeViewWidth = 0
  editorPaneWidth = 0
  editorPaneOriginX = 0

  @content: ->
    @div class: 'resize-pane-handle'

  initialize: (pane) ->
    @pane = pane
    @handleEvents()

  destroy: ->
    this.off('mousedown')
    this.remove();

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
