-- Lua filter to style .question divs for Typst output
-- Adds left border accent using USYD brand red

function Div(el)
  if el.classes:includes("question") then
    -- Only apply for Typst output
    if quarto.doc.is_format("typst") then
      local open = pandoc.RawBlock('typst', [[
#block(
  inset: (left: 1em),
  stroke: (left: 4pt + rgb("#e64626"))
)[
]])
      local close = pandoc.RawBlock('typst', ']')

      local blocks = pandoc.List({open})
      blocks:extend(el.content)
      blocks:insert(close)

      return blocks
    end
  elseif el.classes:includes("ans") then
    -- Only apply for Typst output
    if quarto.doc.is_format("typst") then
      local open = pandoc.RawBlock('typst', [[
#block(
  fill: rgb("#e64626").lighten(94%),
  inset: 1em,
  width: 100%
)[
]])
      local close = pandoc.RawBlock('typst', ']')

      local blocks = pandoc.List({open})
      blocks:extend(el.content)
      blocks:insert(close)

      return blocks
    end
  end
  return el
end
