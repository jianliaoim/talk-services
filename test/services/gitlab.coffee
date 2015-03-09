should = require 'should'
gitlab = require '../../src/services/gitlab'
{setting} = gitlab

describe 'GitLab#Setting', ->

  it 'should have title, description and iconUrl properties', ->

    setData = setting.toJSON()

    setData.should.have.properties 'title', 'description', 'iconUrl', 'requires', 'options'
    setData.title.should.eql 'GitLab'
    setData.requires.should.have.properties '_roomId', 'url'
