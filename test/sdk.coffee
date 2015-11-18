# Mock server sdk

Promise = require 'bluebird'
should = require 'should'

module.exports = sdk =
  getAccountUser: (accountToken, callback) ->
    accountToken.should.not.be.empty
    callback null,
      _id: '5639af7cc5186af927fe88c7'
      accountToken: "xxx"
      unions: [{
        _id: "55fceb7daaaaaaa43bd66751",
        refer: "teambition",
        openId: "51f08418c794aaaaa00107dd",
        name: "lurenjia",
        accessToken: "some account token",
        showname: "lurenjia@jianliao.com",
        updatedAt: "2015-11-17T09:01:32.108Z",
        createdAt: "2015-09-19T04:58:37.588Z",
      }]

Promise.promisifyAll sdk
