# Exercism

This is a nix shell for reproducible exercism in multiple languages. This is all the tooling you need:

- [Nix](https://nixos.org/)
- [direnv](https://direnv.net/)

## Usage

Create or edit the `.config/exercism/user.json` file, and dump the following content
```json
{
  "apibaseurl": "https://api.exercism.io/v1",
  "token": "<YOUR-API-TOKEN>",
  "workspace": "<PATH-TO-THIS-REPO>"
}
```

then you can proceed to do exercism in your favorite (supported) languages, adding support for more is easy.

```shell
$ cd erlang
direnv: loading ~/<YOUR_PATH>/.envrc
direnv: using flake .#erlang --impure
direnv: nix-direnv: Using cached dev shell
Starting Erlang environment...
# <...>
$ exercism download --track=erlang --exercise=difference-of-squares

Downloaded to
/<YOUR_PATH>/exercism/erlang/difference-of-squares
```
now just solve your exercise,
```shell
# <...>
$ cd difference-of-squares
# <...>
$ rebar3 eunit
# <...>
# =======================================================
#  All 9 tests passed.
$ exercism submit src/difference_of_squares.erl  
```

## Supported Languages

1. Elixir
2. Erlang
3. F#
4. Gleam
5. Haskell

