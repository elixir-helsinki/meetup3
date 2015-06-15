defmodule Mix.Tasks.Meetup3 do
  use Mix.Task
  
  @shortdoc "meetup3 example task"
  
  def run(_) do
    #Application.ensure_all_started(:hackney)
    
    # :hackney_pool.start_pool(:default, [])
    # :hackney_pool.set_max_connections(:default, 5000)

    :inets.start # for :httpc.request/4
    
    tasks = File.stream!(Meetup3.path_to_file)
    |> Stream.take(1000)
    |> Stream.chunk(10)
    |> Enum.map(
      fn chunk ->
        Task.async(fn -> process_chunk(chunk) end)
      end)
    |> Enum.reduce(HashSet.new, fn task, acc -> HashSet.put(acc, task.ref) end)
    
    result = receive_loop(tasks, []) |> List.flatten

    IO.puts ""
    IO.puts "==== Most Popular Webservers Out There ===="
    IO.puts ""
    
    count_stats(result)
    |> HashDict.to_list
    |> List.keysort(1)
    |> Enum.reverse
    |> Enum.with_index
    |> Enum.each(
      fn {{server, count}, idx} ->
        idx = to_string(idx)
        IO.puts "#{String.rjust(idx, 3)}. #{inspect server} (#{count})"
      end)

    IO.puts ""
    IO.puts "==========================================="
    IO.puts ""
  end
  
  def process_chunk(chunk) do
    Enum.map(chunk,
      fn line ->
        [_rank, host] = String.strip(line) |> String.split(",")
        case do_http_head_request(:httpc, "www.#{host}") do
          {:ok, headers} ->
            server = List.keyfind(headers, 'server', 0)
            if server != nil do
              {'server', server} = server
              # server header has usually version number appended after "/"
              String.split(to_string(server), "/") |> List.first
            end
          {:error, _reason} ->
            :error
        end
      end)
  end

  defp receive_loop(tasks, acc) do
    if HashSet.size(tasks) == 0 do
      acc
    else
      receive do
        {ref, msg} ->
          tasks = HashSet.delete(tasks, ref)
          receive_loop(tasks, [msg | acc])
        {:'DOWN', ref, :process, _, _} ->
          tasks = HashSet.delete(tasks, ref)
          receive_loop(tasks, acc)
      end
    end
  end
  
  defp do_http_head_request(:hackney, host) do
    case :hackney.connect(:hackney_tcp_transport, host, 80, [recv_timeout: 5000,
                                                             connect_timeout: 10000]) do
      {:ok, conn} ->
        case :hackney.send_request(conn, {:head, "/", [], ""}) do
          {:ok, _, headers} ->
            {:ok, headers}
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_http_head_request(:httpc, host) do
    response = :httpc.request(:head, {String.to_char_list("http://#{host}"), []},
                              [timeout: 2000, connect_timeout: 5000, autoredirect: false], [])
    case response do
      {:ok, {_, headers, _}} ->
        {:ok, headers}
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  defp count_stats(servers), do: count_stats(servers, HashDict.new)

  defp count_stats([], acc), do: acc
  defp count_stats([server | servers], acc) do
    case HashDict.fetch(acc, server) do
      {:ok, count} ->
        # increase the count for the server
        count_stats(servers, HashDict.put(acc, server, count + 1))
      :error ->
        # initialize count for the server
        count_stats(servers, HashDict.put_new(acc, server, 1))
    end
  end
  
end
