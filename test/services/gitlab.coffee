should = require 'should'
gitlab = require '../../src/services/gitlab'
{setting} = gitlab

describe 'GitLab#Setting', ->

  it 'should have title, description and iconUrl properties', ->

    setData = setting.toJSON()

    setData.should.have.properties 'title', 'description', 'iconUrl', 'fields'
    setData.title.should.eql 'GitLab'
    setData.fields.should.have.properties '_roomId', 'url'
