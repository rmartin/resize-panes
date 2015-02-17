{$, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'
path = require 'path'
ResizePaneView = require '../lib/resize-pane-view'
ResizePane = require '../lib/main'

describe "Resize Pane", ->
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)

    waitsForPromise ->
      atom.workspace.open('sample.js')
    waitsForPromise ->
      atom.packages.activatePackage('resize-panes')

  describe ".activate()", ->
    it "does not add resize panel for single panes", ->
      expect(workspaceElement.querySelectorAll('.pane').length).toBe 1
      expect(workspaceElement.querySelectorAll('.pane > .resize-pane-handle').length).toBe 0

  describe "Pane Split Scenarios", ->
    it "should add a resize pane to the first editor when there are two horizontal panes", ->
      expect(workspaceElement.querySelectorAll('.pane').length).toBe 1
      expect(workspaceElement.querySelectorAll('.pane > .resize-pane-handle').length).toBe 0

      pane1 = atom.workspace.getActivePane()
      pane2 = pane1.splitRight()
      pane2.activate()
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelectorAll('.pane').length).toBe 2
      expect(workspaceElement.querySelectorAll('.resize-pane-handle').length).toBe 1

    it "should add a resize pane to the first and second editor when there are three horizontal panes", ->
      expect(workspaceElement.querySelectorAll('.pane').length).toBe 1
      expect(workspaceElement.querySelectorAll('.pane > .resize-pane-handle').length).toBe 0

      pane1 = atom.workspace.getActivePane()
      pane2 = pane1.splitRight()
      pane2.activate()
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelectorAll('.pane').length).toBe 2
      expect(workspaceElement.querySelectorAll('.resize-pane-handle').length).toBe 1

      pane3 = pane2.splitRight()
      pane3.activate()
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelectorAll('.pane').length).toBe 3
      expect(workspaceElement.querySelectorAll('.resize-pane-handle').length).toBe 2
