# Exercism

This is a nix shell for reproducible exercism in multiple languages. This is all the tooling you need:

- [Nix](https://nixos.org/)

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
<...>
$ exercism download --track=erlang --exercise=difference-of-squares

Downloaded to
/<YOUR_PATH>/exercism/erlang/difference-of-squares
```
