# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # Ecto magic
    from: 2,
    defenum: 2,
    defenum: 3,
    belongs_to: 2,
    belongs_to: 3,
    has_one: 2,
    has_one: 3,
    has_many: 2,
    has_many: 3,
    many_to_many: 2,
    many_to_many: 3,
    field: 2,
    field: 3,

    # Registry directory
    defregdir: 2
  ]
]
