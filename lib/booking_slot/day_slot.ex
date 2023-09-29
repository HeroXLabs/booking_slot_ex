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

  def from_end_time(time, min_per_slot \\ 15)

  def from_end_time(%Time{} = time, min_per_slot) do
    total_min = get_total_minutes_with_slot_considered(time, min_per_slot)
    slot_num = to_slot_num(total_min, min_per_slot)
    {:ok, %__MODULE__{id: slot_num}}
  end

  def from_end_time(time_str, min_per_slot) when is_binary(time_str) do
    with {:ok, time} <- Time.new(time_str) do
      from_end_time(time, min_per_slot)
    end
  end

  def to_time_str(_, min_per_slot \\ 15)

  def to_time_str(%__MODULE__{id: 0}, _min_per_slot) do
    "12:00am"
  end

  def to_time_str(%__MODULE__{id: day_slot_num}, min_per_slot) do
    total_min = day_slot_num * min_per_slot
    hour_digit = round_floor(total_min, 60)
    minute_digit = rem(total_min, 60)

    suffix =
      case round_floor(hour_digit, 12) do
        0 -> "am"
        1 -> "pm"
      end

    minute = String.pad_leading(to_string(minute_digit), 2, "0")
    hour = to_string(normalize_hour_digit(hour_digit))
    num_part = Enum.join([hour, minute], ":")
    Enum.join([num_part, suffix])
  end

  defp normalize_hour_digit(12), do: 12
  defp normalize_hour_digit(n), do: rem(n, 12)

  defp to_slot_num(minutes, min_per_slot) do
    round_floor(minutes, min_per_slot)
  end

  defp round_floor(a, b) do
    round(Float.floor(a / b))
  end

  defp get_total_minutes(%Time{hour: hour, minute: minute}) do
    hour * 60 + minute
  end

  defp get_total_minutes_with_slot_considered(%Time{hour: hour, minute: minute}, min_per_slot) do
    min = round(Float.ceil(minute / min_per_slot)) * min_per_slot
    hour * 60 + min
  end
end
