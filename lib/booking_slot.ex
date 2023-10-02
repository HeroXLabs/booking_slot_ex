defmodule BookingSlot do
  @moduledoc """
  Documentation for BookingSlot.
  """
  alias __MODULE__.{DaySlot, ConsolidatedSlot, Result, Time}
  import Calendar.DateTime, only: [shift_zone!: 2]

  @total_min_in_a_day 24 * 60 
  @slot_length_in_min Application.compile_env(:booking_slot, :slot_length_in_min)

  def shift_slots(slots, 0) do
    slots
  end

  def shift_slots(slots, shift_num) do
    total_slots = total_slots_in_a_day()

    shifted_slots =
      slots
      |> Enum.map(fn slot -> %{slot | id: slot.id + shift_num} end)

    positive_shifted_slots =
      shifted_slots
      |> Enum.filter(&(&1.id >= 0))

    overflowed_positive_shifted_slots =
      positive_shifted_slots
      |> Enum.filter(&(&1.id > 95))
      |> Enum.map(fn slot -> %{slot | id: slot.id - total_slots} end)

    non_overflowed_positive_shifted_slots =
      positive_shifted_slots
      |> Enum.filter(&(&1.id <= 95))

    negative_shifted_slots =
      shifted_slots
      |> Enum.filter(&(&1.id < 0))
      |> Enum.map(fn slot -> %{slot | id: slot.id + total_slots} end)

    overflowed_positive_shifted_slots ++ non_overflowed_positive_shifted_slots ++ negative_shifted_slots
  end

  def day_slot_from_datetime(datetime_utc, timezone) do
    time =
      datetime_utc
      |> shift_zone!(timezone)
      |> DateTime.to_time()

    time
    |> Time.from_time()
    |> day_slot_from_time()
  end

  def to_time_str(day_slot) do
    DaySlot.to_time_str(day_slot)
  end

  def union(day_slots_1, day_slots_2) do
    (day_slots_1 ++ day_slots_2)
    |> Enum.uniq_by(& &1.id)
    |> Enum.sort(&(&1.id < &2.id))
  end

  def intersect(day_slots_1, day_slots_2) do
    day_slots_1_ids = day_slots_1 |> Enum.map(& &1.id)

    day_slots_2
    |> Enum.filter(&Enum.member?(day_slots_1_ids, &1.id))
    |> Enum.sort(&(&1.id < &2.id))
  end

  def subtract(day_slots_1, day_slots_2) do
    day_slots_2_ids = day_slots_2 |> Enum.map(& &1.id)

    day_slots_1
    |> Enum.filter(&(not Enum.member?(day_slots_2_ids, &1.id)))
    |> Enum.sort(&(&1.id < &2.id))
  end

  def matched_slots(day_slots, length) do
    day_slots
    |> consolidate_slots()
    |> Enum.filter(&(&1.length >= length))
    |> Enum.map(&remove_tail_slots(&1, length))
    |> unconsolidate_slots()
  end

  defp remove_tail_slots(%ConsolidatedSlot{length: slot_length} = consolidated_slot, length) do
    %{consolidated_slot | length: slot_length - (length - 1)}
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
    0..(length - 1)
    |> Enum.map(&DaySlot.new(starting_id + &1))
  end

  def day_slots_from_times({start_time_str, end_time_str}) do
    with {:ok, %DaySlot{id: start_day_slot_num}} <- day_slot_from_time(start_time_str),
         {:ok, %DaySlot{id: end_day_slot_num}} <- day_slot_from_time(end_time_str, true) do
      {:ok,
       start_day_slot_num..(end_day_slot_num - 1)
       |> Enum.map(&DaySlot.new(&1))}
    end
  end

  def day_slots_from_times(list) when is_list(list) do
    list
    |> Enum.map(&day_slots_from_times/1)
    |> Result.choose()
  end

  def day_slot_from_time(time_str, is_end \\ false) do
    if is_end do
      DaySlot.from_end_time(time_str)
    else
      DaySlot.from_time(time_str)
    end
  end

  def slot_length_in_min() do
    @slot_length_in_min
  end

  def total_slots_in_a_day() do
    round(@total_min_in_a_day / @slot_length_in_min)
  end

  defp do_consolidate_slots(%ConsolidatedSlot{} = consolidated_slot, []) do
    {consolidated_slot, []}
  end

  defp do_consolidate_slots(
         %ConsolidatedSlot{id: starting_id, length: length} = consolidated_slot,
         [slot | rest] = prev_rest
       ) do
    if slot.id == starting_id + length do
      %{consolidated_slot | length: length + 1}
      |> do_consolidate_slots(rest)
    else
      {consolidated_slot, prev_rest}
    end
  end
end
