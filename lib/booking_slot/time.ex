defmodule BookingSlot.Time do
  defstruct [:hour, :minute]

  def from_time(%Time{} = time) do
    %__MODULE__{hour: time.hour, minute: time.minute}
  end

  def new(time_str) do
    parse_time(time_str)
  end

  defp build(12, min, "am") do
    %__MODULE__{hour: 0, minute: min}
  end

  defp build(hr, min, "am") do
    %__MODULE__{hour: hr, minute: min}
  end

  defp build(12, min, "pm") do
    %__MODULE__{hour: 12, minute: min}
  end

  defp build(hr, min, "pm") do
    %__MODULE__{hour: hr + 12, minute: min}
  end

  defp parse_time(time) do
    case Regex.run(~r/(1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm])/, time) do
      [_, hr_str, min_str, suffix] ->
        time = build(String.to_integer(hr_str), String.to_integer(min_str), suffix)
        {:ok, time}
      _ ->
        {:error, "invalid_format"}
    end
  end
end
