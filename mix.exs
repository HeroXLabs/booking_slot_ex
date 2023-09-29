defmodule BookingSlot.MixProject do
  use Mix.Project

  def project do
    [
      app: :booking_slot,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:calendar, "~> 0.17.2"},
      {:ssl_verify_fun, "~> 1.1.7"}
    ]
  end
end
