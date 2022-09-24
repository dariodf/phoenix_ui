defmodule PhoenixUI.Components.AvatarGroup do
  @moduledoc """
  Provides avatar_group component.
  """
  import PhoenixUI.Components.Avatar, only: [avatar: 1]

  use PhoenixUI, :component

  attr(:border, :boolean, default: true)
  attr(:color, :string, default: "slate")
  attr(:element, :string, default: "div")
  attr(:max, :integer, default: 5)
  attr(:size, :string, default: "md")
  attr(:spacing, :string, default: "md")
  attr(:variant, :string, default: "circular")

  slot(:avatar, required: true)

  @doc """
  Renders avatar_group component.

  ## Examples

      ```
      <.avatar_group>
        <:avatar src={@src1}/>
        <:avatar src={@src2}/>
        <:avatar src={@src3}/>
        ...
      </.avatar_group>
      ```

  """
  @spec avatar_group(Socket.assigns()) :: Rendered.t()
  def avatar_group(pre_assigns) do
    assigns =
      pre_assigns
      |> calc_total()
      |> calc_extra()
      |> build_avatar_group_attrs()
      |> normalize_avatars()

    ~H"""
    <.dynamic_tag {@avatar_group_attrs}>
      <%= if (@total - @max) > 0 do %>
        <.avatar
          border={@border}
          color={@color}
          extend_class={"avatar-group-avatar -ml-#{spacing_mapping(@spacing)}"}
          size={@size}
          variant={@variant}
        >
          +<%= @total - @max %>
        </.avatar>
      <% end %>
      <%= for avatar <- @avatar do %>
        <.avatar {avatar} />
      <% end %>
    </.dynamic_tag>
    """
  end

  @doc """
  Returns all possible component classes for Tailwind CSS JIT compilation.

  ## Examples

      iex> classes()
      ["class1", "class2", ...]

  """
  @spec classes :: [String.t()]
  def classes do
    generate_all_classes(&avatar_group/1,
      avatar: [[%{inner_block: nil}]],
      color: Theme.colors(),
      inner_block: [nil, []],
      size: ["xs", "sm", "md", "lg", "xl"],
      spacing: ["xs", "sm", "md", "lg", "xl"],
      variant: ["circular", "rounded", "square"]
    )
  end

  defp calc_total(%{avatar: avatars} = assigns) do
    assign_new(assigns, :total, fn -> length(avatars) end)
  end

  defp calc_extra(%{max: max, total: total} = assigns) do
    assign_new(assigns, :extra, fn -> total - max end)
  end

  ### Avatar Group Attrs ##########################

  defp build_avatar_group_attrs(assigns) do
    spacing = spacing_mapping(assigns[:spacing])

    class = build_class(~w(
      avatar-group inline-flex flex-row-reverse items-center pl-#{spacing}
      #{Map.get(assigns, :extend_class)}
    ))

    attrs =
      assigns
      |> assigns_to_attributes([
        :avatar,
        :border,
        :color,
        :element,
        :extend_class,
        :size,
        :variant
      ])
      |> Keyword.put_new(:class, class)
      |> Keyword.put(:name, assigns[:element])

    assign(assigns, :avatar_group_attrs, attrs)
  end

  ### Normalize Avatars ##########################

  defp normalize_avatars(%{avatar: [_ | _] = avatars, max: max, total: total} = assigns) do
    take_count = if max >= total, do: total, else: max
    spacing = spacing_mapping(assigns[:spacing])

    avatar =
      avatars
      |> Enum.take(take_count)
      |> Enum.map(fn avatar ->
        extend_class = build_class(~w(
          avatar-group-avatar -ml-#{spacing}
          #{Map.get(avatar, :extend_class)}
        ))

        avatar
        |> Map.put_new(:border, assigns[:border])
        |> Map.put_new(:color, assigns[:color])
        |> Map.put_new(:size, assigns[:size])
        |> Map.put_new(:variant, assigns[:variant])
        |> Map.put(:extend_class, extend_class)
      end)
      |> Enum.reverse()

    assign(assigns, :avatar, avatar)
  end

  defp spacing_mapping("xs"), do: "2.5"
  defp spacing_mapping("sm"), do: "2"
  defp spacing_mapping("md"), do: "1.5"
  defp spacing_mapping("lg"), do: "1"
  defp spacing_mapping("xl"), do: "0.5"
end
