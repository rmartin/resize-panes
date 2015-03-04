path = require 'path'
shell = require 'shell'
{BufferedProcess, CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'


toggleConfig = (keyPath) ->
  atom.config.set(keyPath, not atom.config.get(keyPath))


module.exports =
class ResizePaneView extends View
  panel: null
  orientation: null
  editorPaneDimension = 0
  editorPaneOrigin = 0

  @content: ->
    @div class: 'resize-pane-handle'

  initialize: (pane, orientation) ->
    @pane = pane
    @orientation = orientation
    this.element.setAttribute('class', this.element.getAttribute('class') + ' ' + orientation)
    @handleEvents()

  destroy: ->
    this.off('mousedown')
    this.remove();

  handleEvents: ->
    $(this).on('mousedown', (e) => @resizeStarted(e));

  resizeStarted: ({pageX, pageY, which}) =>
    if @orientation is "horizontal"
      editorPaneDimension = $(@pane).width()
      editorPaneOrigin = pageX
    else
      editorPaneDimension = $(@pane).height()
      editorPaneOrigin = pageY
    $(document).on('mousemove', @resizePaneView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizePaneView)
    $(document).off('mouseup', @resizeStopped)

  resizePaneView: ({pageX, pageY, which}) =>
    return @resizeStopped() unless which is 1
    if @orientation is "horizontal"
      flexResizeSize = (editorPaneDimension + (pageX - editorPaneOrigin)).toString()
      $(@pane).css('flex', '0 1 ' + flexResizeSize + 'px')
    else
      flexResizeSize = (editorPaneDimension + (pageY - editorPaneOrigin)).toString()
      $(@pane).css('flex', '0 1 ' + flexResizeSize + 'px')
