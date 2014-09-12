class AuthHandler
  constructor: (auth_data) ->
    @auth_data = auth_data

  validate: (request, response) ->
    @command = null
    @args = []
    return false unless (request.body?.text? && request.body?.token?)

    if request.body.token in @auth_data.tokens
      parts = request.body.text.split ' '
      if parts.length > 0
        @command = parts.shift()
        while parts.length > 0
          @args.push parts.shift()
        return true

    response.serveJSON null, {
      httpStatusCode: 401,
    }
    return false

module.exports = (auth_data) ->
  return new AuthHandler(auth_data)
