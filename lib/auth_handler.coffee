class AuthHandler
  constructor: (auth_data) ->
    @auth_data = auth_data

  validate: (request, response) ->
    @command = null
    @argument = null
    return false unless (request.body?.text? && request.body?.token?)

    if request.body.token in @auth_data.tokens
      parts = request.body.text.split ' '
      if parts.length > 0
        @command = parts[0]
        @argument = parts[1] if parts.length > 1
        return true

    response.serveJSON null, {
      httpStatusCode: 401,
    }
    return false

module.exports = (auth_data) ->
  return new AuthHandler(auth_data)
