defmodule BookingSlotTest do
  use ExUnit.Case
  doctest BookingSlot
  alias BookingSlot.{DaySlot,ConsolidatedSlot,Time}
  import Calendar.DateTime, only: [from_erl!: 2, shift_zone!: 2]

  test "#to_time_str" do
    assert BookingSlot.to_time_str(%DaySlot{id: 36}) == "9:00am"
    assert BookingSlot.to_time_str(%DaySlot{id: 37}) == "9:15am"
    assert BookingSlot.to_time_str(%DaySlot{id: 37}) == "9:15am"
    assert BookingSlot.to_time_str(%DaySlot{id: 38}) == "9:30am"
  end

  test "#day_slot_from_time" do
    assert BookingSlot.day_slot_from_time("9:00am") == {:ok, %DaySlot{id: 36}}
    assert BookingSlot.day_slot_from_time("9:15am") == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_time("9:29am") == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_time("9:30am") == {:ok, %DaySlot{id: 38}}
  end

  test "#day_slot_from_datetime" do
    timezone = "America/Los_Angeles"
    time_1 = from_erl!({{2019,6,1}, {9,0,1}},  timezone)
    time_2 = from_erl!({{2019,6,1}, {9,15,3}}, timezone)
    time_3 = from_erl!({{2019,6,1}, {9,29,4}}, timezone)
    time_4 = from_erl!({{2019,6,1}, {9,30,5}}, timezone)

    assert BookingSlot.day_slot_from_datetime(shift_zone!(time_1, "Etc/UTC"), timezone) == {:ok, %DaySlot{id: 36}}
    assert BookingSlot.day_slot_from_datetime(shift_zone!(time_2, "Etc/UTC"), timezone) == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_datetime(shift_zone!(time_3, "Etc/UTC"), timezone) == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_datetime(shift_zone!(time_4, "Etc/UTC"), timezone) == {:ok, %DaySlot{id: 38}}
  end

  test "#day_slot_from_time with Time input" do
    assert BookingSlot.day_slot_from_time(%Time{hour: 9, minute: 0}) == {:ok, %DaySlot{id: 36}}
    assert BookingSlot.day_slot_from_time(%Time{hour: 9, minute: 15}) == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_time(%Time{hour: 9, minute: 29}) == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_time(%Time{hour: 9, minute: 30}) == {:ok, %DaySlot{id: 38}}
  end

  test "#day_slots_from_times" do
    assert BookingSlot.day_slots_from_times({"9:00am", "9:30am"}) == {:ok, [%DaySlot{id: 36}, %DaySlot{id: 37}]}
    {:ok, day_slots} = BookingSlot.day_slots_from_times({"9:00am", "1:15pm"})
    assert Enum.count(day_slots) == 17
  end

  test "#union" do
    result = BookingSlot.union([
      %BookingSlot.DaySlot{id: 25},
      %BookingSlot.DaySlot{id: 36},
      %BookingSlot.DaySlot{id: 37},
      %BookingSlot.DaySlot{id: 52}
    ], [
      %BookingSlot.DaySlot{id: 23},
      %BookingSlot.DaySlot{id: 36}
    ])

    assert result == [
      %BookingSlot.DaySlot{id: 23},
      %BookingSlot.DaySlot{id: 25},
      %BookingSlot.DaySlot{id: 36},
      %BookingSlot.DaySlot{id: 37},
      %BookingSlot.DaySlot{id: 52}
    ]
  end

  test "#subtract" do
    result = BookingSlot.subtract([
      %BookingSlot.DaySlot{id: 23},
      %BookingSlot.DaySlot{id: 25},
      %BookingSlot.DaySlot{id: 36},
      %BookingSlot.DaySlot{id: 37},
      %BookingSlot.DaySlot{id: 52}
    ], [
      %BookingSlot.DaySlot{id: 23},
      %BookingSlot.DaySlot{id: 36},
      %BookingSlot.DaySlot{id: 38}
    ])

    assert result == [
      %BookingSlot.DaySlot{id: 25},
      %BookingSlot.DaySlot{id: 37},
      %BookingSlot.DaySlot{id: 52}
    ]
  end

  test "#matched_slots" do
    day_slots = [
      %BookingSlot.DaySlot{id: 25},
      %BookingSlot.DaySlot{id: 36},
      %BookingSlot.DaySlot{id: 37},
      %BookingSlot.DaySlot{id: 52},
      %BookingSlot.DaySlot{id: 53},
      %BookingSlot.DaySlot{id: 54},
      %BookingSlot.DaySlot{id: 60},
      %BookingSlot.DaySlot{id: 61},
      %BookingSlot.DaySlot{id: 62},
      %BookingSlot.DaySlot{id: 63}
    ]

    assert BookingSlot.matched_slots(day_slots, 3) == [
      %BookingSlot.DaySlot{id: 52},
      %BookingSlot.DaySlot{id: 53},
      %BookingSlot.DaySlot{id: 54},
      %BookingSlot.DaySlot{id: 60},
      %BookingSlot.DaySlot{id: 61},
      %BookingSlot.DaySlot{id: 62},
      %BookingSlot.DaySlot{id: 63}
    ]

    assert BookingSlot.matched_slots(day_slots, 4) == [
      %BookingSlot.DaySlot{id: 60},
      %BookingSlot.DaySlot{id: 61},
      %BookingSlot.DaySlot{id: 62},
      %BookingSlot.DaySlot{id: 63}
    ]

    assert BookingSlot.matched_slots(day_slots, 5) == []
  end

  test "#day_slots_from_times with array" do
    assert BookingSlot.day_slots_from_times([{"9:00am", "9:30am"}, {"1:00pm", "2:30pm"}]) ==
      {:ok,
        [
          %BookingSlot.DaySlot{id: 36},
          %BookingSlot.DaySlot{id: 37},
          %BookingSlot.DaySlot{id: 52},
          %BookingSlot.DaySlot{id: 53},
          %BookingSlot.DaySlot{id: 54},
          %BookingSlot.DaySlot{id: 55},
          %BookingSlot.DaySlot{id: 56},
          %BookingSlot.DaySlot{id: 57}
        ]}

    assert BookingSlot.day_slots_from_times([{"11:00am", "12:00pm"}]) ==
      {:ok,
        [
          %BookingSlot.DaySlot{id: 44},
          %BookingSlot.DaySlot{id: 45},
          %BookingSlot.DaySlot{id: 46},
          %BookingSlot.DaySlot{id: 47}
        ]}
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
