_ = require 'underscore-plus'
ResizePaneMouseView = require './resize-pane-mouse-view'
{$, View} = require 'atom-space-pen-views'

module.exports =
  resizePanel: null

  activate: () ->
    resizePaneMouseViews = []

    @paneSubscription = atom.workspace.observePanes (pane) =>

      paneElement = atom.views.getView(pane)
      resizePaneMouseView = new ResizePaneMouseView(paneElement)
      resizePanel = resizePaneMouseView
      $(paneElement).append(resizePaneMouseView)

      pane.onWillDestroyItem =>
        $('.pane').each (i,elm) =>
          $(elm).attr('style','')

      pane.onDidDestroy =>
        _.remove(resizePaneMouseViews, resizePaneMouseView)

  deactivate: ->
    @paneSubscription.dispose()
    resizePaneMouseView.destroy() for resizePaneMouseView in resizePaneMouseViews
