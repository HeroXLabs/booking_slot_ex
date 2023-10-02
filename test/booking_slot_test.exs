defmodule BookingSlotTest do
  use ExUnit.Case
  doctest BookingSlot
  alias BookingSlot.{DaySlot,ConsolidatedSlot,Time}
  import Calendar.DateTime, only: [from_erl!: 2, shift_zone!: 2]

  test "#shift_slots" do
    slots =  [
      %BookingSlot.DaySlot{id: 0},
      %BookingSlot.DaySlot{id: 1},
      %BookingSlot.DaySlot{id: 2},
      %BookingSlot.DaySlot{id: 3},
      %BookingSlot.DaySlot{id: 4},
      %BookingSlot.DaySlot{id: 5},
      %BookingSlot.DaySlot{id: 6},
      %BookingSlot.DaySlot{id: 7},
      %BookingSlot.DaySlot{id: 76},
      %BookingSlot.DaySlot{id: 77},
      %BookingSlot.DaySlot{id: 78},
      %BookingSlot.DaySlot{id: 79},
      %BookingSlot.DaySlot{id: 80},
      %BookingSlot.DaySlot{id: 81},
      %BookingSlot.DaySlot{id: 82},
      %BookingSlot.DaySlot{id: 83},
      %BookingSlot.DaySlot{id: 84},
      %BookingSlot.DaySlot{id: 85},
      %BookingSlot.DaySlot{id: 86},
      %BookingSlot.DaySlot{id: 87},
      %BookingSlot.DaySlot{id: 88},
      %BookingSlot.DaySlot{id: 89},
      %BookingSlot.DaySlot{id: 90},
      %BookingSlot.DaySlot{id: 91},
      %BookingSlot.DaySlot{id: 92},
      %BookingSlot.DaySlot{id: 93},
      %BookingSlot.DaySlot{id: 94},
      %BookingSlot.DaySlot{id: 95}
    ]

    shifted_slots = BookingSlot.shift_slots(slots, -50)

    assert shifted_slots == [
      %BookingSlot.DaySlot{id: 26},
      %BookingSlot.DaySlot{id: 27},
      %BookingSlot.DaySlot{id: 28},
      %BookingSlot.DaySlot{id: 29},
      %BookingSlot.DaySlot{id: 30},
      %BookingSlot.DaySlot{id: 31},
      %BookingSlot.DaySlot{id: 32},
      %BookingSlot.DaySlot{id: 33},
      %BookingSlot.DaySlot{id: 34},
      %BookingSlot.DaySlot{id: 35},
      %BookingSlot.DaySlot{id: 36},
      %BookingSlot.DaySlot{id: 37},
      %BookingSlot.DaySlot{id: 38},
      %BookingSlot.DaySlot{id: 39},
      %BookingSlot.DaySlot{id: 40},
      %BookingSlot.DaySlot{id: 41},
      %BookingSlot.DaySlot{id: 42},
      %BookingSlot.DaySlot{id: 43},
      %BookingSlot.DaySlot{id: 44},
      %BookingSlot.DaySlot{id: 45},
      %BookingSlot.DaySlot{id: 46},
      %BookingSlot.DaySlot{id: 47},
      %BookingSlot.DaySlot{id: 48},
      %BookingSlot.DaySlot{id: 49},
      %BookingSlot.DaySlot{id: 50},
      %BookingSlot.DaySlot{id: 51},
      %BookingSlot.DaySlot{id: 52},
      %BookingSlot.DaySlot{id: 53}
    ]

    shifted_back_slots = BookingSlot.shift_slots(shifted_slots, 50)
    assert slots == shifted_back_slots
  end

  test "#to_time_str" do
    assert BookingSlot.to_time_str(%DaySlot{id: 0}) == "12:00am"
    assert BookingSlot.to_time_str(%DaySlot{id: 1}) == "12:15am"
    assert BookingSlot.to_time_str(%DaySlot{id: 36}) == "9:00am"
    assert BookingSlot.to_time_str(%DaySlot{id: 37}) == "9:15am"
    assert BookingSlot.to_time_str(%DaySlot{id: 37}) == "9:15am"
    assert BookingSlot.to_time_str(%DaySlot{id: 38}) == "9:30am"
    assert BookingSlot.to_time_str(%DaySlot{id: 90}) == "10:30pm"
  end

  test "#day_slot_from_time" do
    assert BookingSlot.day_slot_from_time("12:00am") == {:ok, %DaySlot{id: 0}}
    assert BookingSlot.day_slot_from_time("11:59pm") == {:ok, %DaySlot{id: 95}}
    assert BookingSlot.day_slot_from_time("12:00am", true) == {:ok, %DaySlot{id: 96}}
    assert BookingSlot.day_slot_from_time("2:00pm") == {:ok, %DaySlot{id: 56}}
    assert BookingSlot.day_slot_from_time("9:00am") == {:ok, %DaySlot{id: 36}}
    assert BookingSlot.day_slot_from_time("9:15am") == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_time("9:29am") == {:ok, %DaySlot{id: 37}}
    assert BookingSlot.day_slot_from_time("9:30am") == {:ok, %DaySlot{id: 38}}
  end

  test "#day_slot_from_datetime" do
    timezone = "America/Los_Angeles"
    time_0 = from_erl!({{2019,6,1}, {0,0,0}},  timezone)
    time_1 = from_erl!({{2019,6,1}, {9,0,1}},  timezone)
    time_2 = from_erl!({{2019,6,1}, {9,15,3}}, timezone)
    time_3 = from_erl!({{2019,6,1}, {9,29,4}}, timezone)
    time_4 = from_erl!({{2019,6,1}, {9,30,5}}, timezone)

    assert BookingSlot.day_slot_from_datetime(shift_zone!(time_0, "Etc/UTC"), timezone) == {:ok, %DaySlot{id: 0}}
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
    assert BookingSlot.day_slot_from_time(%Time{hour: 0, minute: 0}) == {:ok, %DaySlot{id: 0}}
    assert BookingSlot.day_slot_from_time(%Time{hour: 0, minute: 15}) == {:ok, %DaySlot{id: 1}}
  end

  test "#day_slots_from_times" do
    assert BookingSlot.day_slots_from_times({"12:00pm", "12:30pm"}) == {:ok, [%BookingSlot.DaySlot{id: 48}, %BookingSlot.DaySlot{id: 49}]}
    assert BookingSlot.day_slots_from_times({"12:00pm", "12:15pm"}) == {:ok, [%BookingSlot.DaySlot{id: 48}]}
    assert BookingSlot.day_slots_from_times({"12:00pm", "12:20pm"}) == {:ok, [%BookingSlot.DaySlot{id: 48}, %BookingSlot.DaySlot{id: 49}]}
    assert BookingSlot.day_slots_from_times({"9:00am", "9:30am"}) == {:ok, [%DaySlot{id: 36}, %DaySlot{id: 37}]}
    assert BookingSlot.day_slots_from_times({"12:00am", "12:45am"}) == {:ok, [%DaySlot{id: 0}, %DaySlot{id: 1}, %DaySlot{id: 2}]}
    assert BookingSlot.day_slots_from_times({"10:00pm", "11:55pm"}) == {:ok, [
      %DaySlot{id: 88}, 
      %DaySlot{id: 89}, 
      %DaySlot{id: 90},
      %DaySlot{id: 91},
      %DaySlot{id: 92},
      %DaySlot{id: 93},
      %DaySlot{id: 94},
      %DaySlot{id: 95}
    ]}
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

  test "#intersect" do
    result = BookingSlot.intersect([
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
      %BookingSlot.DaySlot{id: 23},
      %BookingSlot.DaySlot{id: 36}
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
      %BookingSlot.DaySlot{id: 60},
      %BookingSlot.DaySlot{id: 61}
    ]

    assert BookingSlot.matched_slots(day_slots, 4) == [
      %BookingSlot.DaySlot{id: 60}
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
