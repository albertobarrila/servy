defmodule Servy.Handler do

  @moduledoc """
    handles HTTP requests.
  """

  alias Servy.Conv
  alias Servy.BearController

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, emojify: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc """
    transform the request intoa response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> emojify
    |> track
    |> format_response
  end



  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    Path.expand("../../pages", __DIR__)
      |> Path.join("form.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
      @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/"<>file} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join(file)
    |> File.read
    |> handle_file(conv)
end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts response
