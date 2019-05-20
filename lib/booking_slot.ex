defmodule BookingSlot do
  @moduledoc """
  Documentation for BookingSlot.
  """
  alias __MODULE__.{Time,DaySlot,ConsolidatedSlot,Result}

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
    |> Enum.map(& %DaySlot{id: starting_id + &1})
  end

  def day_slots_from_times({start_time_str, end_time_str}) do
    with {:ok, %DaySlot{id: start_day_slot_num}} <- day_slot_from_time(start_time_str),
         {:ok, %DaySlot{id: end_day_slot_num}} <- day_slot_from_time(end_time_str) do
      {:ok,
        start_day_slot_num .. end_day_slot_num - 1
        |> Enum.map(& %DaySlot{id: &1}) }
    end
  end

  def day_slots_from_times(list) when is_list(list) do
    list
    |> Enum.map(&day_slots_from_times/1)
    |> Result.choose()
  end

  def day_slot_from_time(time_str) when is_binary(time_str) do
    with {:ok, time} <- parse_time(time_str) do
      slot_num =
        time
        |> get_total_minutes()
        |> to_slot_num()

      {:ok, %DaySlot{id: slot_num}}
    end
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

  defp parse_time(time) do
    case Regex.run(~r/(1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm])/, time) do
      [_, hr_str, min_str, suffix] ->
        time = to_time(hr_str, min_str, suffix)
        {:ok, time}
      _ ->
        {:error, "invalid_format"}
    end
  end

  defp to_slot_num(minutes) do
    Kernel.round(Float.floor(minutes / 15))
  end

  defp get_total_minutes(%Time{hour: hour, minute: minute}) do
    hour * 60 + minute
  end

  defp to_time(hr, min, "am") do
    %Time{hour: String.to_integer(hr), minute: String.to_integer(min)}
  end

  defp to_time(hr, min, "pm") do
    %Time{hour: String.to_integer(hr) + 12, minute: String.to_integer(min)}
  end
end
