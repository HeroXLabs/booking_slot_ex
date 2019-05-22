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

  defp to_slot_num(minutes, min_per_slot) do
    Kernel.round(Float.floor(minutes / min_per_slot))
  end

  defp get_total_minutes(%Time{hour: hour, minute: minute}) do
    hour * 60 + minute
  end
end
