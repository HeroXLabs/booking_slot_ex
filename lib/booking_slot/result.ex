defmodule BookingSlot.Result do
  def choose(results) do
    {:ok,
      results
      |> Enum.map(&do_choose/1)
      |> Enum.filter(& not(is_nil(&1)))
      |> List.flatten()}
  end

  def do_choose({:ok, value}), do: value
  def do_choose(_), do: nil
end
