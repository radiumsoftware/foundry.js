class NullAdapter
  save: (klass, record) ->
    record

exports.Foundry ||= {}
exports.Foundry.NullAdapter = NullAdapter
