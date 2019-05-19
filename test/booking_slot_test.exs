defmodule BookingSlotTest do
  use ExUnit.Case
  doctest BookingSlot
  alias BookingSlot.{DaySlot,ConsolidatedSlot}

  test "#day_slot_from_time" do
    assert BookingSlot.day_slot_from_time("9:00am") == {:ok, %DaySlot{id: 36}}
    assert BookingSlot.day_slot_from_time("9:15am") == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_time("9:29am") == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_time("9:30am") == {:ok, %DaySlot{id: 38}}
  end

  test "#day_slots_from_times" do
    assert BookingSlot.day_slots_from_times({"9:00am", "9:30am"}) == {:ok, [%DaySlot{id: 36}, %DaySlot{id: 37}]}
    {:ok, day_slots} = BookingSlot.day_slots_from_times({"9:00am", "1:15pm"})
    assert Enum.count(day_slots) == 17
  end

  test "#consolidate_slots" do
    consolidated_slots =
      [%DaySlot{id: 36}, %DaySlot{id: 37}, %DaySlot{id: 38}, %DaySlot{id: 40}, %DaySlot{id: 42}, %DaySlot{id: 43}]
      |> BookingSlot.consolidate_slots()
    assert consolidated_slots ==
      [%ConsolidatedSlot{id: 36, length: 3}, %ConsolidatedSlot{id: 40, length: 1}, %ConsolidatedSlot{id: 42, length: 2}]
  end

  test "#unconsolidate_slots" do
    consolidated_slots = [%ConsolidatedSlot{id: 36, length: 3}, %ConsolidatedSlot{id: 40, length: 1}, %ConsolidatedSlot{id: 42, length: 2}]
    day_slots =
      consolidated_slots
      |> BookingSlot.unconsolidate_slots()
    assert day_slots == [%DaySlot{id: 36}, %DaySlot{id: 37}, %DaySlot{id: 38}, %DaySlot{id: 40}, %DaySlot{id: 42}, %DaySlot{id: 43}]
  end
end
