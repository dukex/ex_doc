defmodule ExDoc.CLITest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  defp run(args) do
    ExDoc.CLI.run(args, &{&1, &2, &3})
  end

  test "minimum command-line options" do
    assert {"ExDoc", "1.2.3", [extras: [], source_beam: "/"]} == run(["ExDoc", "1.2.3", "/"])
  end

  test "loading config" do
    File.write!("test.config", ~s([key: "val"]))

    {project, version, opts} = run(["ExDoc", "--extra", "README.md", "1.2.3", "...", "-c", "test.config"])

    assert project == "ExDoc"
    assert version == "1.2.3"
    assert Enum.sort(opts) == [extras: ["README.md"], formatter_opts: [key: "val"], source_beam: "..."]
  after
    File.rm!("test.config")
  end

  test "config does not exists" do
    assert_raise File.Error,
                 fn -> run(["ExDoc", "1.2.3", "...", "-c", "test.config"]) end
  end

  test "config must be a keyword list" do
    File.write!("test.config", ~s(%{"extras" => "README.md"}))

    assert_raise RuntimeError,
                 "expected a keyword list from config file: \"test.config\"",
                 fn -> run(["ExDoc", "1.2.3", "...", "-c", "test.config"]) end
  after
    File.rm!("test.config")
  end

  test "version" do
    assert capture_io( fn ->
      run(["--version"])
    end) == "ExDoc v#{ExDoc.version}\n"

    assert capture_io( fn ->
      run(["-v"])
    end) == "ExDoc v#{ExDoc.version}\n"
  end

end
