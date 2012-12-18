class NullAdapter
  save: (klass, record) ->
    record

if exports != undefined
  exports.Foundry.NullAdapter = NullAdapter
else if window != undefined
  window.Foundry = NullAdapter
