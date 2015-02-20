_ = require 'underscore-plus'
ResizePaneView = require './resize-pane-view'
{$, View} = require 'atom-space-pen-views'
# include event-kit as a dependency if you want to use this
{CompositeDisposable} = require 'event-kit'

module.exports =
  isFirstLoad: true
  paneAxisCollection: []
  resizePaneViews: []

  # Package is activated on Atom start
  activate: () ->
    @subscriptions = new CompositeDisposable

    @subscribeToPaneAxis()

    # Listen for changes to pane and attach listeners to the Pane Axis
    @subscriptions.add atom.workspace.observePanes (pane) =>
      if not @isFirstLoad
        @subscribeToPaneAxis()

    @isFirstLoad = false

  getpaneAxisCollection: ->
    @paneAxisCollection

  ###
  Subscribe to changes in the Pane Axis for add / removal of childen elements.
  Leverages a class element to determine if subscriptions are needed for Pane
  Axis.
  ###
  subscribeToPaneAxis: ->
    _.each atom.workspace.getPanes(), (paneItem) =>
      # Ensure we have a Pane Axis by method inspecting onDidAddChild
      currPaneAxis = paneItem.parent
      currPaneAxis.assignId()

      # Get the current pane Axis and resize views
      paneAxisCollection = @getpaneAxisCollection()

      # Only add a new subscription if the Pane Axis DOM doesn't exist in the
      # collection
      if not _.findWhere(paneAxisCollection, {'id' : currPaneAxis.id} )?

        if currPaneAxis.onDidAddChild?
          paneAxisSubscriptions = new CompositeDisposable
          paneAxisCollection.push({
            'id': currPaneAxis.id,
            'subscriptions': paneAxisSubscriptions,
            'resizePanes': []} )

          # Bootstrap initial load
          @insertResizePanes(currPaneAxis)

          # Listen for new children being added to the view and re-calc resize
          # panes
          paneAxisSubscriptions.add currPaneAxis.onDidAddChild =>
            @insertResizePanes(currPaneAxis)

          # Adjust resize panes when panel is closed
          paneAxisSubscriptions.add currPaneAxis.onDidRemoveChild =>
            @removeResizePanes(currPaneAxis)
            @insertResizePanes(currPaneAxis)

          # Remove all resize panes and subscriptions when pane axis is
          # destroyed
          paneAxisSubscriptions.add currPaneAxis.onDidDestroy (paneElement) =>
            # Remove all resize panes within the pane axis
            currResizePanesInPaneAxis = @getResizePanesInPaneAxis(currPaneAxis)
            _.each currResizePanesInPaneAxis.resizePanes, (resizePane) ->
              resizePane.destroy()
            currResizePanesInPaneAxis.subscriptions.dispose()

  # Helper method to return the current pane element for a given pane
  getPaneElement: (pane) ->
    atom.views.getView(pane)

  # Helper method to return all panes within the current pane axis
  getPanesInPaneAxis: (currPaneAxis) ->
    currPaneAxis.getPanes()

  # Helper method to return all resize editors within a given pane axis
  getResizePanesInPaneAxis: (currPaneAxis) ->
    _.findWhere(@paneAxisCollection, {'id' : currPaneAxis.id} )

  # Insert resize pane after the pane element.
  insertResizePane: (paneElement, currPaneAxis) ->
    resizePaneView = new ResizePaneView(paneElement)
    resizePaneView.insertAfter(paneElement)

    # Add view to Pane Axis resize pane
    currResizePanesInPaneAxis = @getResizePanesInPaneAxis(currPaneAxis)
    currResizePanesInPaneAxis.resizePanes.push(resizePaneView)

  # Insert resize panes for all panes in a pane axis. Excluded when only one
  # pane or last pane(s) on the right
  insertResizePanes: (currPaneAxis) ->
    editorPanes = @getPanesInPaneAxis(currPaneAxis)

    # Loop through all panes and add a resize container (except last pane).
    # Keep track of all panes in array to avoid search for them for removal
    _.each editorPanes, (pane) =>
      paneElement = @getPaneElement(pane)
      currClass = paneElement.nextSibling.getAttribute('class')
      if paneElement.nextSibling? and currClass isnt 'resize-pane-handle'
        @insertResizePane(paneElement, currPaneAxis)

  # Remove all resize panes present in the current pane axis
  removeResizePanes: (currPaneAxis) ->
    editorPanes = @getPanesInPaneAxis(currPaneAxis)

    # Remove the custom fluxbox styles within the given pane axis
    _.each editorPanes, (pane) =>
      paneElement = @getPaneElement(pane)
      paneElement.setAttribute('style', '')

    # Remove all resize panes within the pane axis
    currResizePanesInPaneAxis = @getResizePanesInPaneAxis(currPaneAxis)
    _.each currResizePanesInPaneAxis.resizePanes, (resizePane) ->
      resizePane.destroy()

  removeAllResizePanes: =>
    _.each @paneAxisCollection, (currResizePanesInPaneAxis) ->
      _.each currResizePanesInPaneAxis.resizePanes, (resizePane) ->
        resizePane.destroy()
      currResizePanesInPaneAxis.subscriptions.dispose()

  # Clean-up when destorying views
  deactivate: ->
    @removeResizeAllPanes()
    @subscriptions.dispose()
