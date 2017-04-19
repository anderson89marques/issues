defmodule CliTest do
  use ExUnit.Case
  doctest Issues

  import Issues.CLI, only: [parse_args: 1]

  test ":help deve ser retornado quando passado as opções -h e --help" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "passando user, project, count deve-se retornar {user, project, count}" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "passando user, project deve-se retornar {user, project, 4}" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end
end
