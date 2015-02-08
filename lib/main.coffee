_ = require 'underscore-plus'
ResizePaneMouseView = require './resize-pane-mouse-view'
{$, View} = require 'atom-space-pen-views'

module.exports =
  resizePanel: null

  activate: () ->
    @resizePaneMouseViews = []
    @paneSubscription = atom.workspace.observePanes (pane) =>
      paneElement = atom.views.getView(pane)
      if !$(paneElement).is(':only-child') && !$(paneElement).is(':last-child')
        resizePaneMouseView = new ResizePaneMouseView(paneElement)
        $(resizePaneMouseView).insertAfter(paneElement)
        @resizePaneMouseViews.push(resizePaneMouseView)
        pane.onDidDestroy => _.remove(@resizePaneMouseViews, resizePaneMouseView)

  deactivate: ->
    @paneSubscription.dispose()
    resizePaneMouseView.remove() for resizePaneMouseView in @resizePaneMouseViews
