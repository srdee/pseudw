fs = require('fs')

###
  class Annotator
    annotate: (string) -> [tokens]
    reset: () ->
###

class SimpleAnnotator
  annotate: (string) ->
    for token in string.split(' ')
      form: token
  reset: () -> # stateless, so no-op

class TreebankAnnotator
  constructor: (@treebank) ->
    @reset()
  annotate: (string) ->
    result = []

    while string.length
      annotation = @treebank[@i++]
      form = annotation.originalForm || annotation.form
      if (original = string[0...form.length]) != form
        throw "Original '#{original}' not equal to '#{form}': #{JSON.stringify(annotation)}"
      result.push(annotation)
      string = string[form.length..].trim()
    result

  reset: () ->
    @i = 0

class TreebankAnnotatorIndex
  @load: (dir) ->
    resources = {}
    for file in fs.readdirSync(dir)
      pid = 'Perseus:text:' + file.replace('.json', '')
      resources[pid] = dir + '/' + file

    new TreebankAnnotatorIndex(resources)

  constructor: (@resources) ->

  pid: (pid, next) ->
    return next("resource not found") unless resource = @resources[pid]
    fs.readFile(resource, (err, file) ->
      return next(err) if err

      next(null, new TreebankAnnotator(JSON.parse(file))))

module.exports =
  SimpleAnnotator: SimpleAnnotator
  TreebankAnnotator: TreebankAnnotator
  TreebankAnnotatorIndex: TreebankAnnotatorIndex
