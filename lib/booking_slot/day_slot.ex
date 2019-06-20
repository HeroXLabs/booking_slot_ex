defmodule BookingSlot.DaySlot do
  alias BookingSlot.Time

  defstruct id: nil

  def new(id) do
    %__MODULE__{id: id}
  end

  def from_time(time, min_per_slot \\ 15)

  def from_time(%Time{} = time, min_per_slot) do
    slot_num =
      time
      |> get_total_minutes()
      |> to_slot_num(min_per_slot)

    {:ok, %__MODULE__{id: slot_num}}
  end

  def from_time(time_str, min_per_slot) when is_binary(time_str) do
    with {:ok, time} <- Time.new(time_str) do
      from_time(time, min_per_slot)
    end
  end

  def to_time_str(%__MODULE__{id: day_slot_num}, min_per_slot \\ 15) do
    total_min = day_slot_num * min_per_slot
    hour_digit = round_floor(total_min, 60)
    minute_digit = rem(total_min, 60)

    suffix =
      case round_floor(hour_digit, 12) do
        0 -> "am"
        1 -> "pm"
      end

    minute = String.pad_leading(to_string(minute_digit), 2, "0")
    hour = to_string(rem(hour_digit, 12))
    num_part = Enum.join([hour, minute], ":")
    Enum.join([num_part, suffix])
  end

  defp to_slot_num(minutes, min_per_slot) do
    round_floor(minutes, min_per_slot)
  end

  defp round_floor(a, b) do
    round(Float.floor(a / b))
  end

  defp get_total_minutes(%Time{hour: hour, minute: minute}) do
    hour * 60 + minute
  end
end
