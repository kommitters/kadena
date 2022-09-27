defmodule Kadena.Types.ChainIDTest do
  @moduledoc """
  `ChainID` struct definition tests.
  """

  alias Kadena.Types.ChainID

  use ExUnit.Case

  describe "new/1" do
    test "with a valid " do
      %ChainID{id: "2"} = ChainID.new("2")
    end

    test "with an invalid value " do
      {:error, [id: :invalid]} = ChainID.new(2)
    end

    test "with an invalid nil value " do
      {:error, [id: :invalid]} = ChainID.new(nil)
    end
  end
end
