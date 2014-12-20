require! 'asyncblock'

{querycollection, allcollection, anytrue, alltrue, haskeys, matchval} = require './logquery'

main = ->
  users = {}
  allcollection 'quiz', (data) ->
    correct = data.answers.filter((x) -> x.iscorrect).length
    unanswered = data.answers.filter((x) -> x.myanswer == '--- select a word ---').length
    vocab = data.vocab ? data.lang
    console.log data.username, vocab, data.quiztype, correct, unanswered

main()