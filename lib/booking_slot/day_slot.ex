defmodule BookingSlot.DaySlot do
  alias BookingSlot.Time

  defstruct id: nil

  def new(id) do
    %__MODULE__{id: id}
  end

  def from_time(%Time{} = time) do
    slot_num =
      time
      |> get_total_minutes()
      |> to_slot_num()

    {:ok, %__MODULE__{id: slot_num}}
  end

  def from_time(time_str) when is_binary(time_str) do
    with {:ok, time} <- Time.new(time_str) do
      from_time(time)
    end
  end

  defp to_slot_num(minutes) do
    Kernel.round(Float.floor(minutes / 15))
  end

  defp get_total_minutes(%Time{hour: hour, minute: minute}) do
    hour * 60 + minute
  end
end
