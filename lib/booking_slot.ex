defmodule BookingSlot do
  @moduledoc """
  Documentation for BookingSlot.
  """
  alias __MODULE__.{DaySlot,ConsolidatedSlot,Result}

  def matched_slots(day_slots, length) do
    day_slots
    |> consolidate_slots()
    |> Enum.filter(& &1.length >= length)
    |> unconsolidate_slots()
  end

  def consolidate_slots(slots) do
    consolidate_slots([], slots)
  end

  def consolidate_slots(consolidated_slots, []) do
    consolidated_slots
  end

  def consolidate_slots(consolidated_slots, [slot | rest]) do
    {consolidated_slot, rest_unused_slots} =
      %ConsolidatedSlot{id: slot.id, length: 1}
      |> do_consolidate_slots(rest)

    consolidate_slots(consolidated_slots ++ [consolidated_slot], rest_unused_slots)
  end

  def unconsolidate_slots(consolidated_slots) do
    consolidated_slots
    |> Enum.flat_map(&unconsolidate_slot/1)
  end

  def unconsolidate_slot(%ConsolidatedSlot{id: starting_id, length: length}) do
    0..length - 1
    |> Enum.map(& DaySlot.new(starting_id + &1))
  end

  def day_slots_from_times({start_time_str, end_time_str}) do
    with {:ok, %DaySlot{id: start_day_slot_num}} <- day_slot_from_time(start_time_str),
         {:ok, %DaySlot{id: end_day_slot_num}} <- day_slot_from_time(end_time_str) do
      {:ok,
        start_day_slot_num .. end_day_slot_num - 1
        |> Enum.map(& DaySlot.new(&1)) }
    end
  end

  def day_slots_from_times(list) when is_list(list) do
    list
    |> Enum.map(&day_slots_from_times/1)
    |> Result.choose()
  end

  def day_slot_from_time(time) do
    DaySlot.from_time(time)
  end

  defp do_consolidate_slots(%ConsolidatedSlot{} = consolidated_slot, []) do
    {consolidated_slot, []}
  end

  defp do_consolidate_slots(%ConsolidatedSlot{id: starting_id, length: length} = consolidated_slot, [slot | rest] = prev_rest) do
    if slot.id == starting_id + length do
      %{ consolidated_slot | length: length + 1 }
      |> do_consolidate_slots(rest)
    else
      {consolidated_slot, prev_rest}
    end
  end
end
