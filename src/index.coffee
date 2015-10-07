# Description
#   MRT archive downloader from archive.routeviews.org
#
# Author:
#   Shintaro Kojima <goodies@codeout.net>

HttpClient = require('scoped-http-client')
Parser = require('cheerio')
Tmp = require('tmp')

class MRT
  constructor: (@server) ->
    @cache = {}

  month: ->
    date = new Date()
    date.getUTCFullYear().toString() + '.' + ('0' + (date.getUTCMonth()+1)).slice(-2)

  indexUrl: (month) ->
    "http://archive.routeviews.org/route-views.#{@server}/bgpdata/#{@month()}/RIBS/"

  lastFileUrl: (errorHandler, callback) ->
    url = @indexUrl()
    HttpClient.create(url).get() (err, res, body) ->
      if err
        errorHandler err
        return
      if res.statusCode != 200
        errorHandler "Bad HTTP response: #{res.statusCode}"
        return

      $ = Parser.load(body)
      callback url + $('a').last().attr('href')

  get: (errorHandler, callback) ->
    timeout = process.env.MRT_CACHE_TIMEOUT || 86400000  # 1 day
    if @cache.date && new Date() - @cache['date'] < timeout
      callback @cache.path
      return

    errorHandler "Fresh MRT is not found"
    @lastFileUrl errorHandler, (url) =>
      errorHandler "Downloading #{url} ... please wait"

      HttpClient.create(url, encoding: 'binary').get() (err, res, body) =>
        if err
          errorHandler err
          return
        if res.statusCode != 200
          errorHandler "Bad HTTP response: #{res.statusCode}"
          return

        @write body, url, errorHandler, (path) =>
          @cache.date = new Date()
          @cache.path = path
          errorHandler "Saved as #{path}"
          callback path

  write: (content, url, errorHandler, callback) ->
    path = require('path')
    ext = path.extname(url)

    Tmp.file postfix: ext, (err, path, fd, cleanupCallback) ->
      if err
        errorHandler err
        return

      fs = require('fs')
      fs.writeFile path, content, 'binary', (err) ->
        if err
          errorHandler err
          return
        callback path


module.exports = MRT
