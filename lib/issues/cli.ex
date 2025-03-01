defmodule Issues.CLI do
  import Issues.TableFormatter, only: [print_table_for_columns: 2]
  @default_count 4

   @moduledoc """
   Manuseia a entrada pela linha de comando e redirecionando
   para várias funções e gerando uma tabela das últimas n issues em um
   projeto do github
   """

   def main(argv) do
     argv
     |> parse_args
     |> process
   end

   @doc """
   'argv' pode ser -h ou -help, que retornar :help.

   Senão será um nome de usuário do github mais um nome de projeto e opcionalmente
   a quantidade de issues retornadas.

   Retorna
   """
   def parse_args(argv) do
     parse = OptionParser.parse(argv, switches: [help: :boolean],
                                      aliases:  [h: :help])

     case parse do
       {[help: true], _, _}           -> :help
       {_, [user, project, count], _} -> {user, project, String.to_integer(count)}
       {_, [user, project], _}        -> {user, project, @default_count}
       _                              -> :help
     end
   end

   def process(:help) do
     IO.puts """
     usage: issues <user> <project> [count | #{@default_count}]
     """
     System.halt(0)
   end

   def process({user, project, count}) do
     Issues.GithubIssues.fetch(user, project)
     |> decode_response
     |> convert_to_list_of_hashdict
     |> sort_into_ascending_order
     |> Enum.take(count)
     |> print_table_for_columns(["number", "created_at", "title"])
   end

   def convert_to_list_of_hashdict(list) do
     list
     |> Enum.map(&Enum.into(&1, HashDict.new))
   end

   def sort_into_ascending_order(list) do
     list
     |> Enum.sort( fn(i1, i2) -> i1["created_at"] <= i2["created_at"]  end)
   end

   def decode_response({:ok, body}), do: _decode_response(body)
   defp _decode_response({:ok, body}), do: body

   def decode_response({:error, error}) do
     {_, message} = List.keyfind(error, "message", 0)
     IO.puts "Error fetching from github: #{message}"
     System.halt(2)
   end
end
